import XCTest
import Cocoa
@testable import MemStat

// Mock delegate for testing
class MockTableSectionDelegate: TableSectionDelegate {
    var headerLabelsCreated = 0
    var dataLabelsCreated = 0
    var backgroundsAdded = 0
    var lastSortColumn: ProcessSortColumn?
    var lastSortDescending: Bool?
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField {
        headerLabelsCreated += 1
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        return label
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        dataLabelsCreated += 1
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        return label
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        backgroundsAdded += 1
    }
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        lastSortColumn = sortColumn
        lastSortDescending = sortDescending
    }
}

class TableSectionTests: XCTestCase {
    
    var mockDelegate: MockTableSectionDelegate!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockTableSectionDelegate()
    }
    
    override func tearDown() {
        mockDelegate = nil
        super.tearDown()
    }
    
    func testMemoryTableSectionCreation() {
        let section = MemoryTableSection(y: 100, delegate: mockDelegate)
        
        // Verify section was created with correct frame
        XCTAssertEqual(section.frame.origin.y, 100)
        XCTAssertEqual(section.frame.size.height, 96)
        
        // Verify correct number of UI elements were created
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 3) // Total, Used, Free
        XCTAssertEqual(mockDelegate.dataLabelsCreated, 10) // 3 values + 3 units + 2 separators + 2 pressure labels
        XCTAssertEqual(mockDelegate.backgroundsAdded, 1)
        
        // Verify section title
        let titleLabel = section.subviews.first { ($0 as? NSTextField)?.stringValue == "Memory" }
        XCTAssertNotNil(titleLabel)
    }
    
    func testMemoryTableSectionUpdate() {
        let section = MemoryTableSection(y: 100, delegate: mockDelegate)
        
        // Create test memory stats
        let stats = MemoryStats(
            totalMemory: 17_179_869_184, // 16 GB
            usedMemory: 12_884_901_888,  // 12 GB
            freeMemory: 4_294_967_296,   // 4 GB
            activeMemory: 4_294_967_296,
            inactiveMemory: 2_147_483_648,
            wiredMemory: 4_294_967_296,
            compressedMemory: 2_147_483_648,
            swapTotalMemory: 0,
            swapUsedMemory: 0,
            swapFreeMemory: 0,
            swapIns: 0,
            swapOuts: 0,
            pressure: .normal
        )
        
        section.updateData(with: stats)
        
        // Find and verify data labels
        let labels = section.subviews.compactMap { $0 as? NSTextField }
        
        // Should contain "16" and "GB" for total memory
        XCTAssertTrue(labels.contains { $0.stringValue == "16" })
        XCTAssertTrue(labels.contains { $0.stringValue == "GB" })
        
        // Should contain pressure status
        XCTAssertTrue(labels.contains { $0.stringValue == "Normal" })
    }
    
    func testVirtualTableSectionCreation() {
        let section = VirtualTableSection(y: 200, delegate: mockDelegate)
        
        // Verify section properties
        XCTAssertEqual(section.frame.origin.y, 200)
        XCTAssertEqual(section.frame.size.height, 96)
        
        // Verify UI elements
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 4) // Active, Inactive, Wired, Compressed
        XCTAssertEqual(mockDelegate.dataLabelsCreated, 8) // 4 values + 4 units
        
        // Verify section title
        let titleLabel = section.subviews.first { ($0 as? NSTextField)?.stringValue == "Virtual Memory" }
        XCTAssertNotNil(titleLabel)
    }
    
    func testSwapTableSectionCreation() {
        let section = SwapTableSection(y: 300, delegate: mockDelegate)
        
        // Verify section properties
        XCTAssertEqual(section.frame.origin.y, 300)
        XCTAssertEqual(section.frame.size.height, 75)
        
        // Verify UI elements
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 5) // Total, Used, Free, Swap Ins, Swap Outs
        XCTAssertEqual(mockDelegate.dataLabelsCreated, 9) // 3 values + 3 units + 1 separator + 2 counts
    }
    
    func testProcessTableSectionCreation() {
        let section = ProcessTableSection(y: 400, delegate: mockDelegate)
        
        // Verify section properties
        XCTAssertEqual(section.frame.origin.y, 400)
        XCTAssertEqual(section.frame.size.height, 432)
        
        // Verify headers were created
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 6) // PID, Memory %, Memory, Virtual, CPU %, Command
        
        // Verify section title
        let titleLabel = section.subviews.first { ($0 as? NSTextField)?.stringValue == "Top Processes" }
        XCTAssertNotNil(titleLabel)
    }
    
    func testProcessTableSectionUpdate() {
        let section = ProcessTableSection(y: 400, delegate: mockDelegate)
        
        // Create test process data
        let processes = [
            ProcessInfo(pid: 1234, command: "Safari", memoryPercent: 15.5, 
                       memoryBytes: 1_073_741_824, virtualMemoryBytes: 2_147_483_648, 
                       cpuPercent: 5.2),
            ProcessInfo(pid: 5678, command: "Xcode", memoryPercent: 12.3, 
                       memoryBytes: 805_306_368, virtualMemoryBytes: 1_610_612_736, 
                       cpuPercent: 25.8)
        ]
        
        section.updateData(with: processes)
        
        // Verify process data is displayed
        let labels = section.subviews.compactMap { $0 as? NSTextField }
        
        // Should contain process names
        XCTAssertTrue(labels.contains { $0.stringValue == "Safari" })
        XCTAssertTrue(labels.contains { $0.stringValue == "Xcode" })
        
        // Should contain PIDs
        XCTAssertTrue(labels.contains { $0.stringValue == "1234" })
        XCTAssertTrue(labels.contains { $0.stringValue == "5678" })
        
        // Should contain memory percentages
        XCTAssertTrue(labels.contains { $0.stringValue == "15.5%" })
        XCTAssertTrue(labels.contains { $0.stringValue == "12.3%" })
    }
    
    func testProcessTableSectionSorting() {
        let section = ProcessTableSection(y: 400, delegate: mockDelegate)
        
        // Test clicking on sortable header
        let headerLabels = section.subviews.compactMap { view -> NSTextField? in
            guard let label = view as? NSTextField else { return nil }
            return label.cell is VerticallyCenteredTextFieldCell ? label : nil
        }
        
        // Find the PID header (should be first sortable header)
        if let pidHeader = headerLabels.first {
            // Simulate click on PID header
            section.headerClicked(pidHeader)
            
            // Verify delegate was called with correct sort parameters
            XCTAssertEqual(mockDelegate.lastSortColumn, .pid)
            XCTAssertEqual(mockDelegate.lastSortDescending, false)
        }
    }
    
    func testBaseTableSectionPadding() {
        // Test that padding is applied correctly
        let memorySection = MemoryTableSection(y: 100, delegate: mockDelegate)
        let labels = memorySection.subviews.compactMap { $0 as? NSTextField }
        
        // Headers should have padding
        let headerLabels = labels.filter { label in
            label.cell is VerticallyCenteredTextFieldCell
        }
        
        for header in headerLabels {
            // Verify frame includes padding
            XCTAssertGreaterThan(header.frame.origin.x, 0)
        }
    }
}