Load "../concurrent_analyzer.ring"



# Test Concurrent Operations Analysis

Func Main

    # Simulate concurrent operations
    
    # Operation 1: Data Processing
    startConcurrentOp("op1", "Data Processing")
    acquireRes("op1", "database")
    
    # Operation 2: File Upload (depends on Data Processing)
    startConcurrentOp("op2", "File Upload")
    addOpDependency("op2", "op1")
    blockOp("op2", "Waiting for op1 to complete")
    
    # Operation 3: Image Processing
    startConcurrentOp("op3", "Image Processing")
    acquireRes("op3", "gpu")
    
    # Simulate some work for op1
    for i = 1 to 100000 next
    releaseRes("op1", "database")
    endConcurrentOp("op1")
    
    # Resume op2
    resumeOp("op2")
    acquireRes("op2", "network")
    
    # Simulate some work for op2
    for i = 1 to 50000 next
    releaseRes("op2", "network")
    endConcurrentOp("op2")
    
    # Finish op3
    for i = 1 to 75000 next
    releaseRes("op3", "gpu")
    endConcurrentOp("op3")
    
    # Generate and display report
    ? "Concurrency Analysis Report:"
    ? "==========================="
    ? getConcurrencyReport()
    
    # Export report to file
    exportConcurrencyReport("concurrent_analysis.txt")
    ? "Report exported to concurrent_analysis.txt"
