Load "../advanced_trace.ring"

# Test Advanced Logging Features
Func Main
    # Configure logging
    ADVANCED_TRACE.setLogFile("test_trace.log")
    ADVANCED_TRACE.setLogLevel(ADVANCED_TRACE.LOG_DEBUG)
    
    # Test different log levels
    logDebug("This is a debug message")
    logInfo("This is an info message")
    logWarning("This is a warning message")
    logError("This is an error message")
    
    # Test Performance Monitoring
    startPerformanceMonitor()
    for i = 1 to 1000000 next  # Some work
    endPerformanceMonitor("Loop Test")
    
    # Test Variable Watching
    x = 0
    ADVANCED_TRACE.addWatch("x", func varName, value {
        logDebug("Variable " + varName + " changed to: " + value)
    })
    
    # Change x and check watches
    x = 10
    ADVANCED_TRACE.checkWatches()
    
    # Test Breakpoints
    ADVANCED_TRACE.addBreakPoint("test_advanced.ring", 30, "x > 5")
    
    See "Advanced trace tests completed!" + nl
