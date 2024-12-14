# Advanced Performance Analysis Tools
# Provides detailed performance metrics and analysis

Load "advanced_trace.ring"
Load "memory.ring"


# Create Global Instance
PERF_ANALYZER = new PerformanceAnalyzer

# Helper Functions
func startProfiling funcName
    PERF_ANALYZER.startFunctionProfile(funcName)

func endProfiling funcName
    PERF_ANALYZER.endFunctionProfile(funcName)

func takeMemorySnapshot label
    PERF_ANALYZER.takeMemorySnapshot(label)

func compareMemory label1, label2
    return PERF_ANALYZER.compareMemorySnapshots(label1, label2)

func recordMetric name, value
    PERF_ANALYZER.recordMetric(name, value)

func generatePerformanceReport
    return PERF_ANALYZER.generateReport()

func exportPerformanceReport fileName
    return PERF_ANALYZER.exportToFile(fileName)

Class PerformanceAnalyzer 
    # Properties
    metrics = []
    memorySnapshots = []
    functionCalls = []
    activeProfiles = []
    
    # Memory Units
    BYTES = 1
    KB = 1024
    MB = 1024 * 1024
    
    func init
        metrics = []
        memorySnapshots = []
        functionCalls = []
        activeProfiles = []
    
    # Function Call Profiling
    func startFunctionProfile funcName
        profile = [
            :name = funcName,
            :startTime = clock(),
            :startMemory = memory(),
            :calls = 0
        ]
        activeProfiles + profile
        
    func endFunctionProfile funcName
        for i = len(activeProfiles) to 1 step -1
            if activeProfiles[i][:name] = funcName
                profile = activeProfiles[i]
                duration = (clock() - profile[:startTime]) / 1000
                memoryUsed = memory() - profile[:startMemory]
                
                functionCalls + [
                    :name       = funcName,
                    :duration   = duration,
                    :memoryUsed = memoryUsed,
                    :timestamp  = date() + " " + time()
                ]
                
                del(activeProfiles, i)
                exit
            ok
        next
    
    # Memory Analysis
    func takeMemorySnapshot label
        memorySnapshots + [
            :label     = label,
            :memory    = memory(),
            :timestamp = date() + " " + time()
        ]
    
    func compareMemorySnapshots label1, label2
        snap1 = getSnapshot(label1)
        snap2 = getSnapshot(label2)
        
        if snap1 = null or snap2 = null
            return "Error: Snapshot not found"
        ok
        
        diff = snap2[:memory] - snap1[:memory]
        return [
            :difference          = diff,
            :differenceFormatted = formatMemorySize(diff),
            :startTime           = snap1[:timestamp],
            :endTime             = snap2[:timestamp]
        ]
    
    
    # Performance Metrics
    func recordMetric name, value
        metrics + [
            :name      = name,
            :value     = value,
            :timestamp = date() + " " + time()
        ]
    
    func getMetricAverage name
        total = 0
        count = 0
        
        for metric in metrics
            if metric[:name] = name
                total += metric[:value]
                count++
            ok
        next
        
        if count = 0 return 0 ok
        return total / count
    
    # Analysis Reports
    func generateReport
        report = "=== Performance Analysis Report ===" + nl
        
        # Function Calls Analysis
        report += "Function Calls:" + nl
        report += "---------------" + nl
        for fCall in functionCalls
            report += "Function: " + fCall[:name]  + nl
            report += "Duration: " + fCall[:duration] + " seconds" + nl
            report += "Memory Used: " + formatMemorySize(fCall[:memoryUsed]) + nl
            report += "Timestamp: " + fCall[:timestamp]  + nl + nl
        next
        
        # Memory Analysis
        report += "Memory Snapshots:" + nl
        report += "----------------" + nl
        for snap in memorySnapshots
            report += "Label: " + snap[:label] + nl
            report += "Memory: " + formatMemorySize(snap[:memory]) + nl
            report += "Timestamp: " + snap[:timestamp] + nl + nl
        next
        
        # Metrics Analysis
        report += "Performance Metrics:" + nl
        report += "------------------" + nl
        uniqueMetrics = []
        for metric in metrics
            if not find(uniqueMetrics, metric[:name])
                uniqueMetrics + metric[:name]
                avg = getMetricAverage(metric[:name])
                report += "Metric: " + metric[:name] + nl
                report += "Average: " + avg  + nl
            ok
        next
        
        return report
    
    # Export Results
    func exportToFile fileName
        report = generateReport()
        write(fileName, report)
        return true

	private
 
	func getSnapshot label
        for snap in memorySnapshots
            if snap[:label] = label
                return snap
            ok
        next
        return null
    
    func formatMemorySize bytes
        if bytes < KB
            return "" + bytes + " bytes"
        but bytes < MB
            return "" + (bytes / KB) + " KB"
        else
            return "" + (bytes / MB) + " MB"
        ok
    

