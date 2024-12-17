load "stdlib.ring"

if IsMainSourceFile()

# Test the memory function
see "Memory used by the system: " + memory() + " KB" + nl

ok

# Function to get memory information from the system
func memory()
    
    if  islinux()
        memoryInfo = system("free -m")
        memUsed = extractMemoryUsageLinux(memoryInfo)
    elseif isWindows()
        memoryInfo = SystemCmd("wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value")
        memUsed = extractMemoryUsageWindows(memoryInfo)
    else
        see "Unsupported operating system!" + nl
        return 
    ok
    return memUsed


# Function to extract memory usage from Linux system output
func extractMemoryUsageLinux(output)
    lines = split(output, nl)  # Split the output into lines
    if len(lines) < 2
        return 
    ok
    # Look for the line that starts with "Mem:" (free -m output)
    for line in lines
        if left(line, 4) = "Mem:"
            parts = split(line, " ")
            memUsed = number(parts[2])  # Column for used memory (in MB)
            return memUsed * 1024  # Convert MB to KB
        end
    next

    return 


# Function to extract memory usage from Windows system output
func extractMemoryUsageWindows(output)
    lines = split(output, nl)  # Split the output into lines
    freeMemory = 0
    totalMemory = 0
    cFreeMemory = split(lines[3], "=")[2]
	cTemp = ""
	for x = 2 to len(cFreeMemory) step 2
        cTemp += cFreeMemory[x]
	next
    freeMemory = 0 + cTemp 

    cTemp = "" 
 	cTotalMemory = split(lines[4], "=")[2]
	for x = 2 to len(cTotalMemory) step 2
        cTemp += cTotalMemory[x]
	next
    TotalMemory = 0 + cTemp 
    cTemp = ""  

    # Calculate used memory (total - free)
    memUsed = totalMemory - freeMemory
    return memUsed



