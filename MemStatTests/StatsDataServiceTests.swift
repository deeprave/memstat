import XCTest
import Cocoa
@testable import MemStat

class MockMemoryMonitor: MemoryMonitor {
    var mockStats: MemoryStats
    var lastSortColumn: ProcessSortColumn?
    var lastSortDescending: Bool?
    
    override init() {
        self.mockStats = MemoryStats(
            totalMemory: 8_589_934_592,
            usedMemory: 4_294_967_296,
            freeMemory: 4_294_967_296,
            memoryPressure: "Normal",
            activeMemory: 2_147_483_648,
            inactiveMemory: 1_073_741_824,
            wiredMemory: 1_073_741_824,
            compressedMemory: 0,
            appPhysicalMemory: 1_073_741_824,
            appVirtualMemory: 2_147_483_648,
            anonymousMemory: 1_610_612_736,
            fileBackedMemory: 536_870_912,
            swapTotalMemory: 0,
            swapUsedMemory: 0,
            swapFreeMemory: 0,
            swapUtilization: 0.0,
            swapIns: 0,
            swapOuts: 0,
            topProcesses: [
                ProcessInfo(pid: 1234, memoryPercent: 10.5, memoryBytes: 1_073_741_824, virtualMemoryBytes: 2_147_483_648, cpuPercent: 5.2, command: "Safari"),
                ProcessInfo(pid: 5678, memoryPercent: 8.3, memoryBytes: 805_306_368, virtualMemoryBytes: 1_610_612_736, cpuPercent: 12.8, command: "Xcode")
            ]
        )
        super.init()
    }
    
    override func getMemoryStats(sortBy sortColumn: ProcessSortColumn = .memoryPercent, sortDescending: Bool = true) -> MemoryStats {
        lastSortColumn = sortColumn
        lastSortDescending = sortDescending
        return mockStats
    }
}

class StatsDataServiceTests: XCTestCase {
    
    var dataService: StatsDataService!
    var mockMonitor: MockMemoryMonitor!
    
    override func setUp() {
        super.setUp()
        mockMonitor = MockMemoryMonitor()
        dataService = StatsDataService(memoryMonitor: mockMonitor)
    }
    
    override func tearDown() {
        dataService = nil
        mockMonitor = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(dataService)
        XCTAssertEqual(dataService.currentSortColumn, .memoryPercent)
        XCTAssertTrue(dataService.sortDescending)
    }
    
    func testGetCurrentStats() {
        let stats = dataService.getCurrentStats()
        
        XCTAssertEqual(stats.totalMemory, 8_589_934_592)
        XCTAssertEqual(stats.usedMemory, 4_294_967_296)
        XCTAssertEqual(stats.memoryPressure, "Normal")
        XCTAssertEqual(stats.topProcesses.count, 2)
        
        XCTAssertEqual(mockMonitor.lastSortColumn, .memoryPercent)
        XCTAssertEqual(mockMonitor.lastSortDescending, true)
    }
    
    func testUpdateSortingAndRefresh() {
        dataService.updateSortingAndRefresh(sortColumn: .cpuPercent, sortDescending: false)
        
        XCTAssertEqual(dataService.currentSortColumn, .cpuPercent)
        XCTAssertFalse(dataService.sortDescending)
        
        let stats = dataService.getCurrentStats()
        XCTAssertNotNil(stats)
        XCTAssertEqual(mockMonitor.lastSortColumn, .cpuPercent)
        XCTAssertEqual(mockMonitor.lastSortDescending, false)
    }
    
    func testToggleSortOrder() {
        let initialDescending = dataService.sortDescending
        
        dataService.updateSortingAndRefresh(sortColumn: .memoryPercent, sortDescending: !initialDescending)
        
        XCTAssertEqual(dataService.sortDescending, !initialDescending)
    }
    
    func testChangeSortColumn() {
        dataService.updateSortingAndRefresh(sortColumn: .pid, sortDescending: true)
        XCTAssertEqual(dataService.currentSortColumn, .pid)
        
        dataService.updateSortingAndRefresh(sortColumn: .command, sortDescending: false)
        XCTAssertEqual(dataService.currentSortColumn, .command)
        
        dataService.updateSortingAndRefresh(sortColumn: .virtualMemoryBytes, sortDescending: true)
        XCTAssertEqual(dataService.currentSortColumn, .virtualMemoryBytes)
    }
    
    func testSortHandlerProtocolConformance() {
        XCTAssertTrue(dataService is SortHandler)
    }
    
    func testMultipleGetStatsCallsUseSameSort() {
        dataService.updateSortingAndRefresh(sortColumn: .cpuPercent, sortDescending: false)
        
        _ = dataService.getCurrentStats()
        XCTAssertEqual(mockMonitor.lastSortColumn, .cpuPercent)
        XCTAssertEqual(mockMonitor.lastSortDescending, false)
        
        _ = dataService.getCurrentStats()
        XCTAssertEqual(mockMonitor.lastSortColumn, .cpuPercent)
        XCTAssertEqual(mockMonitor.lastSortDescending, false)
    }
}