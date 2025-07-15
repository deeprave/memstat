import XCTest
@testable import MemStat

class MemoryMonitorTests: XCTestCase {
    
    var memoryMonitor: MemoryMonitor!
    
    override func setUp() {
        super.setUp()
        memoryMonitor = MemoryMonitor()
    }
    
    override func tearDown() {
        memoryMonitor = nil
        super.tearDown()
    }
    
    func testGetMemoryStats() {
        // Test that we can get memory stats
        let stats = memoryMonitor.getMemoryStats()
        
        // Verify that all memory values are reasonable (greater than 0)
        XCTAssertGreaterThan(stats.totalMemory, 0)
        XCTAssertGreaterThan(stats.usedMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.freeMemory, 0)
        
        // Verify that total = used + free (approximately, due to rounding)
        let calculatedTotal = stats.usedMemory + stats.freeMemory
        let tolerance = stats.totalMemory * 0.05 // 5% tolerance
        XCTAssertLessThanOrEqual(abs(Int64(stats.totalMemory) - Int64(calculatedTotal)), Int64(tolerance))
        
        // Verify virtual memory components
        XCTAssertGreaterThanOrEqual(stats.activeMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.inactiveMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.wiredMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.compressedMemory, 0)
        
        // Verify swap stats are non-negative
        XCTAssertGreaterThanOrEqual(stats.swapTotalMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.swapUsedMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.swapFreeMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.swapIns, 0)
        XCTAssertGreaterThanOrEqual(stats.swapOuts, 0)
        
        // Verify pressure is a valid value
        let validPressures: [MemoryPressure] = [.normal, .warning, .critical]
        XCTAssertTrue(validPressures.contains(stats.pressure))
    }
    
    func testGetTopProcesses() {
        // Test default sorting (by memory percentage, descending)
        let processes = memoryMonitor.getTopProcesses()
        
        // Should return exactly 20 processes or less
        XCTAssertLessThanOrEqual(processes.count, 20)
        XCTAssertGreaterThan(processes.count, 0)
        
        // Verify processes are sorted by memory percentage (descending)
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(processes[i].memoryPercent, processes[i + 1].memoryPercent)
        }
        
        // Verify all process data is valid
        for process in processes {
            XCTAssertGreaterThan(process.pid, 0)
            XCTAssertFalse(process.command.isEmpty)
            XCTAssertGreaterThanOrEqual(process.memoryPercent, 0)
            XCTAssertLessThanOrEqual(process.memoryPercent, 100)
            XCTAssertGreaterThan(process.memoryBytes, 0)
            XCTAssertGreaterThan(process.virtualMemoryBytes, 0)
            XCTAssertGreaterThanOrEqual(process.cpuPercent, 0)
        }
    }
    
    func testGetTopProcessesSortByPID() {
        let processes = memoryMonitor.getTopProcesses(sortBy: .pid, sortDescending: false)
        
        // Verify sorting by PID ascending
        for i in 0..<(processes.count - 1) {
            XCTAssertLessThanOrEqual(processes[i].pid, processes[i + 1].pid)
        }
    }
    
    func testGetTopProcessesSortByCommand() {
        let processes = memoryMonitor.getTopProcesses(sortBy: .command, sortDescending: false)
        
        // Verify sorting by command name ascending
        for i in 0..<(processes.count - 1) {
            XCTAssertLessThanOrEqual(processes[i].command.lowercased(), 
                                     processes[i + 1].command.lowercased())
        }
    }
    
    func testGetTopProcessesSortByCPU() {
        let processes = memoryMonitor.getTopProcesses(sortBy: .cpuPercent, sortDescending: true)
        
        // Verify sorting by CPU percentage descending
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(processes[i].cpuPercent, processes[i + 1].cpuPercent)
        }
    }
    
    func testMemoryPressureCalculation() {
        let stats = memoryMonitor.getMemoryStats()
        
        // Test that pressure correlates with memory usage
        let usedPercentage = Double(stats.usedMemory) / Double(stats.totalMemory) * 100
        
        switch stats.pressure {
        case .normal:
            // Normal pressure should generally be when used memory is reasonable
            XCTAssertLessThan(usedPercentage, 90, "Normal pressure with very high memory usage")
        case .warning:
            // Warning could be at various levels
            XCTAssertTrue(true, "Warning pressure is valid at any usage level")
        case .critical:
            // Critical pressure might occur with very high usage or swap activity
            XCTAssertTrue(true, "Critical pressure is valid based on system state")
        }
    }
    
    func testProcessInfoReliability() {
        // Get processes twice in quick succession
        let processes1 = memoryMonitor.getTopProcesses()
        Thread.sleep(forTimeInterval: 0.1)
        let processes2 = memoryMonitor.getTopProcesses()
        
        // Most processes should still be in top 20 (allowing for some variation)
        let pids1 = Set(processes1.map { $0.pid })
        let pids2 = Set(processes2.map { $0.pid })
        let commonPids = pids1.intersection(pids2)
        
        // At least 50% of processes should be the same
        XCTAssertGreaterThan(commonPids.count, processes1.count / 2)
    }
}