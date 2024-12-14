Load "../performance_analyzer.ring"

# Test Performance Analysis Tools
Func Main
    # Test Function Profiling
    testComplexCalculations()
    
    # Test Memory Analysis
    takeMemorySnapshot("start")
    list = list(1, 1000000)  # Create large list
    takeMemorySnapshot("after_list")
    list = null  # Free memory
    takeMemorySnapshot("end")
    
    # Compare memory usage
    ? "Memory Analysis:"
    ? compareMemory("start", "after_list")
    ? compareMemory("after_list", "end")
    
    # Record some metrics
    for i = 1 to 5
        startTime = clock()
        calculateSomething()
        duration = (clock() - startTime) / 1000
        recordMetric("calculation_time", duration)
    next
    
    # Generate and export report
    ? nl + "Generating performance report..."
    ? generatePerformanceReport()
    
    exportPerformanceReport("performance_report.txt")
    ? nl + "Report exported to performance_report.txt"

Func testComplexCalculations
    startProfiling("testComplexCalculations")
    
    # Simulate some complex work
    total = 0
    for i = 1 to 1000000
        total += i
    next
    
    endProfiling("testComplexCalculations")
    return total

Func calculateSomething
    # Simulate some work
    for i = 1 to 10000000 next
