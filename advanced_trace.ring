# Advanced Trace Library Extension
# Provides advanced logging and debugging features



# Create Global Instance
ADVANCED_TRACE = new AdvancedTrace

# Helper Functions
func logDebug message
    ADVANCED_TRACE.log(ADVANCED_TRACE.LOG_DEBUG, message)

func logInfo message
    ADVANCED_TRACE.log(ADVANCED_TRACE.LOG_INFO, message)

func logWarning message
    ADVANCED_TRACE.log(ADVANCED_TRACE.LOG_WARNING, message)

func logError message
    ADVANCED_TRACE.log(ADVANCED_TRACE.LOG_ERROR, message)

func startPerformanceMonitor
    ADVANCED_TRACE.startPerfMon()

func endPerformanceMonitor label
    ADVANCED_TRACE.endPerfMon(label)



Class AdvancedTrace 
    # Log Levels
    LOG_DEBUG = 1
    LOG_INFO = 2
    LOG_WARNING = 3
    LOG_ERROR = 4
    
    # Properties
    logFile = "trace.log"
    logLevel = LOG_INFO
    enableConsole = true
    enableFileLogging = true
    timeFormat = "YYYY-MM-DD HH:MM:SS"

    # Performance Monitoring
    perfStartTime = 0

	# Enhanced Breakpoint System
    breakPoints = []

	# Variable Watch System
    watchList = []


    func init
        if enableFileLogging
            if not fexists(logFile)
                write(logFile, "=== Trace Log Started ===\n")
            ok
        ok
    
    func setLogLevel level
        logLevel = level
    
    func setLogFile file
        logFile = file
        init()
    
    func log level, message
        if level >= logLevel
            logMsg = getTimeStamp() + " [" + getLevelName(level) + "] " + message + nl
            
            if enableConsole
                see logMsg
            ok
            
            if enableFileLogging
                fh = fopen(logFile, "a")
                fwrite(fh, logMsg)
                fclose(fh)
            ok
        ok
    
    
    func addBreakPoint fileName, lineNumber, condition
        breakPoints + [
            :fileName = fileName,
            :lineNumber = lineNumber,
            :condition = condition
        ]
    
    func removeBreakPoint fileName, lineNumber
        for i = 1 to len(breakPoints)
            if breakPoints[i][:fileName] = fileName and 
               breakPoints[i][:lineNumber] = lineNumber
                del(breakPoints, i)
                return true
            ok
        next
        return false
    
    func addWatch varName, callback
        watchList + [
            :varName = varName,
            :callback = callback
        ]
    
    func checkWatches
        for watch in watchList
            try
                eval("value = " + watch[:varName])
					callwatch = watch[:callback]
                call callwatch(watch[:varName], value)
            catch
                log(LOG_ERROR, "Error watching variable: " + watch[:varName])
            done
        next
    
   
    
    func startPerfMon
        perfStartTime = clock()
    
    func endPerfMon label
        if perfStartTime = 0 return ok
        
        duration = (clock() - perfStartTime) / 1000  # Convert to seconds
        log(LOG_INFO, "Performance [" + label + "]: " + duration + " seconds")
        perfStartTime = 0

	private

	func getLevelName level
        switch level
            case LOG_DEBUG   return "DEBUG"
            case LOG_INFO    return "INFO"
            case LOG_WARNING return "WARNING"
            case LOG_ERROR   return "ERROR"
        off
        return "UNKNOWN"

	func getTimeStamp
        date = date()
        time = time()
        return date + " " + time


