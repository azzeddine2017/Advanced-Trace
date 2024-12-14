# Concurrent Operations Analysis Tools
# Provides analysis for concurrent operations and threading

Load "performance_analyzer.ring"

# Create Global Instance
CONCURRENT_ANALYZER = new ConcurrentAnalyzer

# Helper Functions
func startConcurrentOp id, description
    CONCURRENT_ANALYZER.startOperation(id, description)

func endConcurrentOp id
    CONCURRENT_ANALYZER.endOperation(id)

func acquireRes opId, resId
    CONCURRENT_ANALYZER.acquireResource(opId, resId)

func releaseRes opId, resId
    CONCURRENT_ANALYZER.releaseResource(opId, resId)

func addOpDependency opId, dependsOnId
    CONCURRENT_ANALYZER.addDependency(opId, dependsOnId)

func blockOp opId, reason
    CONCURRENT_ANALYZER.blockOperation(opId, reason)

func resumeOp opId
    CONCURRENT_ANALYZER.resumeOperation(opId)

func getConcurrencyReport
    return CONCURRENT_ANALYZER.generateConcurrencyReport()

func exportConcurrencyReport fileName
    return CONCURRENT_ANALYZER.exportToFile(fileName)

Class ConcurrentAnalyzer 
    # Properties
    operations = []
    activeOperations = []
    operationDependencies = []
    resourceUsage = []
    
    # Constants
    OPERATION_STARTED = 1
    OPERATION_COMPLETED = 2
    OPERATION_BLOCKED = 3
    OPERATION_RESUMED = 4
    
    func init
        operations = []
        activeOperations = []
        operationDependencies = []
        resourceUsage = []
    
    # Operation Tracking
    func startOperation operationId, description
        operation = [
            :id             = operationId,
            :description    = description,
            :startTime      = clock(),
            :status         = OPERATION_STARTED,
            :events         = [],
            :blockedTime    = 0,
            :resourcesUsed  = [],
            :dependencies   = []
        ]
        
        addEvent(operationId, "Started operation: " + description)
        operations + operation
        activeOperations + operationId
    
    func endOperation operationId
        operation = findOperation(operationId)
        if operation != null
            operation[:endTime] = clock()
            operation[:duration] = (operation[:endTime] - operation[:startTime]) / 1000
            operation[:status] = OPERATION_COMPLETED
            
            # Remove from active operations
            pos = find(activeOperations, operationId)
            if pos del(activeOperations, pos) ok
            
            addEvent(operationId, "Completed operation")
        ok
    
    # Resource Usage Tracking
    func acquireResource operationId, resourceId
        resource = [
            :operationId = operationId,
            :resourceId  = resourceId,
            :acquireTime = clock()
        ]
        resourceUsage + resource
        
        operation = findOperation(operationId)
        if operation != null
            operation[:resourcesUsed] + resourceId
            addEvent(operationId, "Acquired resource: " + resourceId)
        ok
    
    func releaseResource operationId, resourceId
        for i = len(resourceUsage) to 1 step -1
            if resourceUsage[i][:operationId] = operationId and 
               resourceUsage[i][:resourceId] = resourceId
                resourceUsage[i][:releaseTime] = clock()
                resourceUsage[i][:duration] = (resourceUsage[i][:releaseTime] - 
                                             resourceUsage[i][:acquireTime]) / 1000
                
                addEvent(operationId, "Released resource: " + resourceId)
                exit
            ok
        next
    
    # Dependency Tracking
    func addDependency operationId, dependsOnId
        dependency = [
            :operation = operationId,
            :dependsOn = dependsOnId
        ]
        operationDependencies + dependency
        
        operation = findOperation(operationId)
        if operation != null
            operation[:dependencies] + dependsOnId
            addEvent(operationId, "Added dependency on: " + dependsOnId)
        ok
    
    # Blocking Events
    func blockOperation operationId, reason
        operation = findOperation(operationId)
        if operation != null
            operation[:status] = OPERATION_BLOCKED
            operation[:blockStartTime] = clock()
            addEvent(operationId, "Blocked: " + reason)
        ok
    
    func resumeOperation operationId
        operation = findOperation(operationId)
        if operation != null
            if operation[:blockStartTime] != null
                blockDuration = (clock() - operation[:blockStartTime]) / 1000
                operation[:blockedTime] += blockDuration
            ok
            operation[:status] = OPERATION_RESUMED
            operation[:blockStartTime] = null
            addEvent(operationId, "Resumed operation")
        ok
    
    
    # Analysis and Reports
    func generateConcurrencyReport
        report = "=== Concurrent Operations Analysis Report ===" + nl + nl
        
        # Active Operations
        report += "Currently Active Operations:" + nl
        report += "--------------------------" + nl
        for opId in activeOperations
            operation = findOperation(opId)
            if operation != null
                report += "ID: " + opId  + nl
                report += "Description: " + operation[:description]  + nl
                report += "Status: " + getStatusString(operation[:status])  + nl + nl
            ok
        next
        
        # Completed Operations
        report += "Completed Operations:" + nl
        report += "--------------------" + nl
        for operation in operations
            if operation[:status] = OPERATION_COMPLETED
                report += "ID: " + operation[:id]  + nl
                report += "Description: " + operation[:description]  + nl
                report += "Duration: " + operation[:duration] + " seconds" + nl
                report += "Blocked Time: " + operation[:blockedTime] + " seconds" + nl
                report += "Resources Used: " + len(operation[:resourcesUsed])  + nl
                report += "Dependencies: " + len(operation[:dependencies])  + nl + nl
            ok
        next
        
        # Resource Usage Analysis
        report += "Resource Usage Analysis:" + nl
        report += "----------------------" + nl
        resources = []
        for usage in resourceUsage
            if not find(resources, usage[:resourceId])
                resources + usage[:resourceId]
            ok
        next
        
        for resourceId in resources
            totalTime = 0
            usageCount = 0
            for usage in resourceUsage
                if usage[:resourceId] = resourceId and usage[:releaseTime] != null
                    totalTime += usage[:duration]
                    usageCount++
                ok
            next
            
            if usageCount > 0
                report += "Resource: " + resourceId  + nl
                report += "Total Usage Time: " + totalTime + " seconds" + nl
                report += "Usage Count: " + usageCount  + nl
                report += "Average Usage Time: " + (totalTime/usageCount) + " seconds"  + nl + nl   
            ok
        next
        
        # Dependency Analysis
        report += "Dependency Analysis:" + nl
        report += "-------------------" + nl
        for dep in operationDependencies
            op1 = findOperation(dep[:operation])
            op2 = findOperation(dep[:dependsOn])
            if op1 != null and op2 != null
                report += op1[:description] + " depends on " + op2[:description]  + nl
            ok
        next
        
        return report
    
	# Export Results
    func exportToFile fileName
        write(fileName, generateConcurrencyReport())
        return true
	private

    # Helper Functions
    func findOperation operationId
        for operation in operations
            if operation[:id] = operationId
                return operation
            ok
        next
        return null
    
    func getStatusString status
        switch status
            case OPERATION_STARTED  return "Started"
            case OPERATION_COMPLETED return "Completed"
            case OPERATION_BLOCKED   return "Blocked"
            case OPERATION_RESUMED   return "Resumed"
        off
        return "Unknown"
    # Event Logging
    func addEvent operationId, description
        operation = findOperation(operationId)
        if operation != null
            event = [
                :timestamp = clock(),
                :description = description
            ]
            operation[:events] + event
        ok
    
    


