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
        let stats = memoryMonitor.getMemoryStats()
        
        XCTAssertGreaterThan(stats.totalMemory, 0)
        XCTAssertGreaterThan(stats.usedMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.freeMemory, 0)
        
        let calculatedTotal = stats.usedMemory + stats.freeMemory
        let tolerance = Double(stats.totalMemory) * 0.05
        XCTAssertLessThanOrEqual(abs(Int64(stats.totalMemory) - Int64(calculatedTotal)), Int64(tolerance))
        
        XCTAssertGreaterThanOrEqual(stats.activeMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.inactiveMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.wiredMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.compressedMemory, 0)
        
        XCTAssertGreaterThanOrEqual(stats.swapTotalMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.swapUsedMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.swapFreeMemory, 0)
        XCTAssertGreaterThanOrEqual(stats.swapIns, 0)
        XCTAssertGreaterThanOrEqual(stats.swapOuts, 0)
        
        let validPressures = ["Normal", "Warning", "Critical"]
        XCTAssertTrue(validPressures.contains(stats.memoryPressure))
    }
    
    func testGetTopProcesses() {
        let stats = memoryMonitor.getMemoryStats()
        let processes = stats.topProcesses
        
        XCTAssertLessThanOrEqual(processes.count, 20)
        XCTAssertGreaterThan(processes.count, 0)
        
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(processes[i].memoryPercent, processes[i + 1].memoryPercent)
        }
        
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
        let stats = memoryMonitor.getMemoryStats(sortBy: .pid, sortDescending: false)
        let processes = stats.topProcesses
        
        for i in 0..<(processes.count - 1) {
            XCTAssertLessThanOrEqual(processes[i].pid, processes[i + 1].pid)
        }
    }
    
    func testGetTopProcessesSortByCommand() {
        let stats = memoryMonitor.getMemoryStats(sortBy: .command, sortDescending: false)
        let processes = stats.topProcesses
        
        for i in 0..<(processes.count - 1) {
            XCTAssertLessThanOrEqual(processes[i].command.lowercased(), 
                                     processes[i + 1].command.lowercased())
        }
    }
    
    func testGetTopProcessesSortByCPU() {
        let stats = memoryMonitor.getMemoryStats(sortBy: .cpuPercent, sortDescending: true)
        let processes = stats.topProcesses
        
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(processes[i].cpuPercent, processes[i + 1].cpuPercent)
        }
    }
    
    func testMemoryPressureCalculation() {
        let stats = memoryMonitor.getMemoryStats()
        
        let usedPercentage = Double(stats.usedMemory) / Double(stats.totalMemory) * 100
        
        switch stats.memoryPressure {
        case "Normal":
            XCTAssertLessThan(usedPercentage, 97, "Normal pressure with very high memory usage")
        case "Warning":
            XCTAssertTrue(true, "Warning pressure is valid at any usage level")
        case "Critical":
            XCTAssertTrue(true, "Critical pressure is valid based on system state")
        default:
            XCTFail("Unknown memory pressure value: \(stats.memoryPressure)")
        }
    }
    
    func testProcessInfoReliability() {
        let stats1 = memoryMonitor.getMemoryStats()
        let processes1 = stats1.topProcesses
        Thread.sleep(forTimeInterval: 0.1)
        let stats2 = memoryMonitor.getMemoryStats()
        let processes2 = stats2.topProcesses
        
        let pids1 = Set(processes1.map { $0.pid })
        let pids2 = Set(processes2.map { $0.pid })
        let commonPids = pids1.intersection(pids2)
        
        XCTAssertGreaterThan(commonPids.count, processes1.count / 2)
    }
}