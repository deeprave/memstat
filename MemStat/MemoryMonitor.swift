import Foundation
import Darwin
import Darwin.Mach

let PROC_ALL_PIDS: UInt32 = 1
let PROC_PIDTASKINFO: Int32 = 4
let PROC_PIDPATHINFO_MAXSIZE: Int32 = 4096
let CTL_KERN: Int32 = 1
let KERN_PROCARGS2: Int32 = 49


struct proc_taskinfo {
    var pti_virtual_size: UInt64 = 0
    var pti_resident_size: UInt64 = 0
    var pti_total_user: UInt64 = 0
    var pti_total_system: UInt64 = 0
    var pti_threads_user: UInt64 = 0
    var pti_threads_system: UInt64 = 0
    var pti_policy: Int32 = 0
    var pti_faults: Int32 = 0
    var pti_pageins: Int32 = 0
    var pti_cow_faults: Int32 = 0
    var pti_messages_sent: Int32 = 0
    var pti_messages_received: Int32 = 0
    var pti_syscalls_mach: Int32 = 0
    var pti_syscalls_unix: Int32 = 0
    var pti_csw: Int32 = 0
    var pti_threadnum: Int32 = 0
    var pti_numrunning: Int32 = 0
    var pti_priority: Int32 = 0
}


@_silgen_name("proc_listpids")
func proc_listpids(_ type: UInt32, _ typeinfo: UInt32, _ buffer: UnsafeMutableRawPointer?, _ buffersize: Int32) -> Int32

@_silgen_name("proc_pidinfo")
func proc_pidinfo(_ pid: Int32, _ flavor: Int32, _ arg: UInt64, _ buffer: UnsafeMutableRawPointer, _ buffersize: Int32) -> Int32

@_silgen_name("proc_pidpath")
func proc_pidpath(_ pid: Int32, _ buffer: UnsafeMutableRawPointer, _ buffersize: UInt32) -> Int32

@_silgen_name("sysctl")
func sysctl(_ name: UnsafeMutablePointer<Int32>, _ namelen: UInt32, _ oldp: UnsafeMutableRawPointer?, _ oldlenp: UnsafeMutablePointer<Int>?, _ newp: UnsafeMutableRawPointer?, _ newlen: Int) -> Int32


open class MemoryMonitor {
    
    private var previousCPUData: [Int32: (totalTime: UInt64, timestamp: TimeInterval)] = [:]
    private static let maxCPUDataEntries = 500
    
    private static let cpuCoreCount: Int = {
        var coreCount: Int = 0
        var size = MemoryLayout<Int>.size
        let result = sysctlbyname("hw.ncpu", &coreCount, &size, nil, 0)
        return result == 0 ? coreCount : 1
    }()
    
    private static let timebaseInfo: mach_timebase_info = {
        var info = mach_timebase_info()
        mach_timebase_info(&info)
        return info
    }()
    
    open func getMemoryStats(sortBy: ProcessSortColumn = .memoryPercent, sortDescending: Bool = true) -> MemoryStats {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let _: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        var vmInfo = vm_statistics64()
        var vmCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size) / 4
        
        let _: kern_return_t = withUnsafeMutablePointer(to: &vmInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(),
                                host_flavor_t(HOST_VM_INFO64),
                                $0,
                                &vmCount)
            }
        }
        
        let totalMemory = getTotalMemory()
        let pageSize = UInt64(vm_page_size)
        
        let freePages = UInt64(vmInfo.free_count)
        let inactivePages = UInt64(vmInfo.inactive_count)
        let activePages = UInt64(vmInfo.active_count)
        let wiredPages = UInt64(vmInfo.wire_count)
        let compressedPages = UInt64(vmInfo.compressor_page_count)
        
        let freeMemory = freePages * pageSize
        let activeMemory = activePages * pageSize
        let inactiveMemory = inactivePages * pageSize
        let wiredMemory = wiredPages * pageSize
        let compressedMemory = compressedPages * pageSize
        let usedMemory = activeMemory + inactiveMemory + wiredMemory + compressedMemory
        
        let memoryPressure = getMemoryPressure(
            free: freePages,
            active: activePages,
            inactive: inactivePages,
            wired: wiredPages,
            compressed: compressedPages
        )
        
        let swapUsage = getSwapUsage()
        let swapStats = getSwapStats()
        let topProcesses = getTopProcesses(totalMemory: totalMemory, sortBy: sortBy, sortDescending: sortDescending)
        
        let appPhysicalMemory = topProcesses.reduce(0) { $0 + $1.memoryBytes }
        let appVirtualMemory = topProcesses.reduce(0) { $0 + $1.virtualMemoryBytes }
        
        // Calculate anonymous and file-backed memory
        // Anonymous memory: memory not backed by files (heap, stack, etc.)
        // File-backed memory: memory backed by files (cached files, libraries, etc.)
        // For now, we'll use reasonable approximations:
        // Anonymous ≈ Active + Inactive (simplified)
        // File-backed ≈ Total used memory - Anonymous (simplified)
        let anonymousMemory = activeMemory + inactiveMemory
        let fileBackedMemory = (usedMemory > anonymousMemory) ? (usedMemory - anonymousMemory) : 0
        
        let basic = BasicMemoryInfo(
            totalMemory: totalMemory,
            usedMemory: usedMemory,
            freeMemory: freeMemory,
            memoryPressure: memoryPressure
        )
        
        let detailed = DetailedMemoryInfo(
            activeMemory: activeMemory,
            inactiveMemory: inactiveMemory,
            wiredMemory: wiredMemory,
            compressedMemory: compressedMemory
        )
        
        let app = AppMemoryInfo(
            appPhysicalMemory: appPhysicalMemory,
            appVirtualMemory: appVirtualMemory,
            anonymousMemory: anonymousMemory,
            fileBackedMemory: fileBackedMemory
        )
        
        let swap = SwapInfo(
            swapTotalMemory: swapUsage.total,
            swapUsedMemory: swapUsage.used,
            swapFreeMemory: swapUsage.free,
            swapUtilization: swapUsage.utilization,
            swapIns: swapStats.swapins,
            swapOuts: swapStats.swapouts
        )
        
        return MemoryStats(
            basic: basic,
            detailed: detailed,
            app: app,
            swap: swap,
            topProcesses: topProcesses
        )
    }
    
    private func getTotalMemory() -> UInt64 {
        var size = MemoryLayout<UInt64>.size
        var totalMemory: UInt64 = 0
        
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)
        
        return totalMemory
    }
    
    private func getMemoryPressure(free: UInt64, active: UInt64, inactive: UInt64, wired: UInt64, compressed: UInt64) -> String {
        var pressure: UInt32 = 0
        var size = MemoryLayout<UInt32>.size
        let result = sysctlbyname("vm.memory_pressure", &pressure, &size, nil, 0)
        
        if result == 0 {
            if pressure < 50 {
                return "Normal"
            } else if pressure < 200 {
                return "Warning"
            } else {
                return "Critical"
            }
        } else {
            let totalPages = free + active + inactive + wired + compressed
            let freePercentage = Double(free) / Double(totalPages) * 100
            
            if freePercentage > 20 {
                return "Normal"
            } else if freePercentage > 10 {
                return "Warning"
            } else {
                return "Critical"
            }
        }
    }
    
    private func getSwapUsage() -> (total: UInt64, used: UInt64, free: UInt64, utilization: Double) {
        var swapUsage = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size
        
        let result = sysctlbyname("vm.swapusage", &swapUsage, &size, nil, 0)
        
        if result == 0 {
            let total = swapUsage.xsu_total
            let used = swapUsage.xsu_used
            let free = total - used
            let utilization = total > 0 ? (Double(used) / Double(total)) * 100.0 : 0.0
            
            return (total: total, used: used, free: free, utilization: utilization)
        } else {
            return (total: 0, used: 0, free: 0, utilization: 0.0)
        }
    }
    
    private func getSwapStats() -> (swapins: UInt64, swapouts: UInt64) {
        var vmInfo = vm_statistics64()
        var vmCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size) / 4
        
        let vmKerr: kern_return_t = withUnsafeMutablePointer(to: &vmInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(),
                                host_flavor_t(HOST_VM_INFO64),
                                $0,
                                &vmCount)
            }
        }
        
        if vmKerr == KERN_SUCCESS {
            return (swapins: UInt64(vmInfo.swapins), swapouts: UInt64(vmInfo.swapouts))
        } else {
            return (swapins: 0, swapouts: 0)
        }
    }
    
    private func getTopProcesses(totalMemory: UInt64, sortBy: ProcessSortColumn, sortDescending: Bool) -> [ProcessInfo] {
        var processes: [ProcessInfo] = []
        var currentPids: Set<Int32> = []
        
        let bufferSize = proc_listpids(PROC_ALL_PIDS, 0, nil, 0)
        guard bufferSize > 0 else { return [] }
        
        let pidCount = bufferSize / Int32(MemoryLayout<pid_t>.size)
        var pids = Array<pid_t>(repeating: 0, count: Int(pidCount))
        
        let actualSize = proc_listpids(PROC_ALL_PIDS, 0, &pids, bufferSize)
        guard actualSize > 0 else { return [] }
        
        let actualPidCount = actualSize / Int32(MemoryLayout<pid_t>.size)
        
        for i in 0..<Int(actualPidCount) {
            let pid = pids[i]
            guard pid > 0 else { continue }
            
            currentPids.insert(pid)
            if let processInfo = getProcessInfo(pid: pid, totalMemory: totalMemory) {
                processes.append(processInfo)
            }
        }
        
        let oldPids = Set(previousCPUData.keys).subtracting(currentPids)
        for oldPid in oldPids {
            previousCPUData.removeValue(forKey: oldPid)
        }
        
        if previousCPUData.count > Self.maxCPUDataEntries {
            let sortedByTimestamp = previousCPUData.sorted { $0.value.timestamp < $1.value.timestamp }
            let entriesToRemove = sortedByTimestamp.prefix(previousCPUData.count - Self.maxCPUDataEntries)
            for (pid, _) in entriesToRemove {
                previousCPUData.removeValue(forKey: pid)
            }
        }
        
        if sortBy == .memoryPercent && sortDescending {
            let topMemoryProcesses = processes.sorted { first, second in
                return first.memoryPercent > second.memoryPercent
            }
            return Array(topMemoryProcesses.prefix(20))
        }
        
        let topMemoryProcesses = processes.sorted { first, second in
            return first.memoryPercent > second.memoryPercent
        }
        let selectedProcesses = Array(topMemoryProcesses.prefix(20))

        let comparator: (ProcessInfo, ProcessInfo) -> Bool = { first, second in
            switch sortBy {
            case .pid:
                return first.pid < second.pid
            case .memoryPercent:
                return first.memoryPercent < second.memoryPercent
            case .memoryBytes:
                return first.memoryBytes < second.memoryBytes
            case .virtualMemory:
                return first.virtualMemoryBytes < second.virtualMemoryBytes
            case .virtualMemoryBytes:
                return first.virtualMemoryBytes < second.virtualMemoryBytes
            case .cpuPercent:
                return first.cpuPercent < second.cpuPercent
            case .command:
                return first.command.lowercased() < second.command.lowercased()
            }
        }
        
        return selectedProcesses.sorted { first, second in
            return sortDescending ? !comparator(first, second) : comparator(first, second)
        }
    }
    
    private func getProcessInfo(pid: pid_t, totalMemory: UInt64) -> ProcessInfo? {
        var taskInfo = proc_taskinfo()
        let taskInfoSize = Int32(MemoryLayout<proc_taskinfo>.size)
        
        let result = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, taskInfoSize)
        guard result == taskInfoSize else { return nil }
        
        var pathBuffer = Array<CChar>(repeating: 0, count: Int(PROC_PIDPATHINFO_MAXSIZE))
        let pathResult = proc_pidpath(pid, &pathBuffer, UInt32(PROC_PIDPATHINFO_MAXSIZE))
        
        var processName: String
        
        if let args = getProcessCommandLine(pid: pid), !args.isEmpty {
            let executable = args[0]
            let executableName = extractProcessName(from: executable)
            
            let interpreters = ["node", "python", "python3", "ruby", "java", "perl", "php", "tcl", "wish"]
            
            if interpreters.contains(executableName.lowercased()) && args.count > 1 {
                processName = executableName
                for i in 1..<args.count {
                    let arg = args[i]
                    if !arg.hasPrefix("-") && !arg.isEmpty {
                        let scriptName = extractProcessName(from: arg)
                        if !scriptName.isEmpty {
                            processName = "\(executableName) \(scriptName)"
                            break
                        }
                    }
                }
            } else {
                processName = executableName
            }
        } else if pathResult > 0 {
            let fullPath = String(cString: pathBuffer)
            processName = extractBetterProcessName(pid: pid, fallbackPath: fullPath)
        } else {
            processName = "Process \(pid)"
        }
        
        let physicalMemoryBytes = taskInfo.pti_resident_size
        let virtualMemoryBytes = taskInfo.pti_virtual_size
        let memoryPercent = Double(physicalMemoryBytes) / Double(totalMemory) * 100.0
        let cpuPercent = calculateImprovedCPUPercentage(pid: pid, taskInfo: taskInfo)
        
        return ProcessInfo(
            pid: pid,
            memoryPercent: memoryPercent,
            memoryBytes: physicalMemoryBytes,
            virtualMemoryBytes: virtualMemoryBytes,
            cpuPercent: cpuPercent,
            command: processName
        )
    }
    
    private func calculateImprovedCPUPercentage(pid: pid_t, taskInfo: proc_taskinfo) -> Double {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let totalCPUTime = taskInfo.pti_total_user + taskInfo.pti_total_system
        
        if let previousData = previousCPUData[pid] {
            let timeDelta = currentTime - previousData.timestamp
            let cpuTimeDelta = totalCPUTime - previousData.totalTime
            
            if timeDelta > 0.5 {
                let cpuTimeNanoseconds = cpuTimeDelta * UInt64(Self.timebaseInfo.numer) / UInt64(Self.timebaseInfo.denom)
                let cpuTimeSeconds = Double(cpuTimeNanoseconds) / 1_000_000_000.0
                let cpuPercent = (cpuTimeSeconds / timeDelta) * 100.0
                
                previousCPUData[pid] = (totalTime: totalCPUTime, timestamp: currentTime)
                return min(max(0.0, cpuPercent), 999.9)
            }
        }
        
        previousCPUData[pid] = (totalTime: totalCPUTime, timestamp: currentTime)
        return 0.0
    }
    
    private func getProcessCommandLine(pid: pid_t) -> [String]? {
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var size: Int = 0
        
        let result = sysctl(&mib, 3, nil, &size, nil, 0)
        guard result == 0 && size > 0 else { return nil }
        
        var buffer = Array<UInt8>(repeating: 0, count: size)
        let result2 = sysctl(&mib, 3, &buffer, &size, nil, 0)
        guard result2 == 0 else { return nil }
        
        guard size >= 4 else { return nil }
        
        let argc = buffer.withUnsafeBytes { bytes in
            bytes.load(as: Int32.self)
        }
        
        guard argc > 0 else { return nil }
        
        var offset = 4
        
        while offset < size && buffer[offset] != 0 {
            offset += 1
        }
        
        while offset < size && buffer[offset] == 0 {
            offset += 1
        }
        
        var arguments: [String] = []
        var argCount = 0
        
        while offset < size && argCount < argc {
            let argStart = offset
            
            while offset < size && buffer[offset] != 0 {
                offset += 1
            }
            
            if offset > argStart {
                let argData = Array(buffer[argStart..<offset])
                if let arg = String(bytes: argData, encoding: .utf8) {
                    arguments.append(arg)
                    argCount += 1
                }
            }
            
            offset += 1
        }
        
        return arguments.isEmpty ? nil : arguments
    }
    
    private func extractProcessName(from command: String) -> String {
        let cleanCommand = command.trimmingCharacters(in: .whitespaces)
        
        if let lastSlash = cleanCommand.lastIndex(of: "/") {
            let executablePart = String(cleanCommand[cleanCommand.index(after: lastSlash)...])
            let parts = executablePart.split(separator: " ", maxSplits: 1)
            if parts.count > 1 && String(parts[1]).hasPrefix("-") {
                return String(parts[0])
            } else {
                return executablePart
            }
        } else {
            return String(cleanCommand.split(separator: " ").first ?? Substring(cleanCommand))
        }
    }
    
    private func extractBetterProcessName(pid: pid_t, fallbackPath: String) -> String {
        if let args = getProcessCommandLine(pid: pid) {
            if args.count > 1 {
                let executable = args[0]
                let executableName = extractProcessName(from: executable)
                
                let interpreters = ["node", "python", "python3", "ruby", "java", "perl", "php", "tcl", "wish"]
                
                if interpreters.contains(executableName.lowercased()) {
                    for i in 1..<args.count {
                        let arg = args[i]
                        if !arg.hasPrefix("-") && !arg.isEmpty {
                            let scriptName = extractProcessName(from: arg)
                            if !scriptName.isEmpty {
                                return "\(executableName) \(scriptName)"
                            }
                        }
                    }
                    for i in 1..<min(args.count, 3) {
                        let arg = args[i]
                        if !arg.hasPrefix("-") && !arg.isEmpty {
                            return "\(executableName) \(arg)"
                        }
                    }
                }
                
                return executableName
            } else if !args.isEmpty {
                return extractProcessName(from: args[0])
            }
        }
        
        return extractProcessName(from: fallbackPath)
    }
}
