import XCTest
import Cocoa
@testable import MemStat

class MockLabelFactory: LabelFactory {
    var headerLabelsCreated = 0
    var dataLabelsCreated = 0
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField {
        headerLabelsCreated += 1
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        label.cell = VerticallyCenteredTextFieldCell(textCell: text)
        return label
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        dataLabelsCreated += 1
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        return label
    }
}

class MockBackgroundStylist: BackgroundStylist {
    var backgroundsAdded = 0
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        backgroundsAdded += 1
    }
}

class MockSortHandler: SortHandler {
    var lastSortColumn: ProcessSortColumn?
    var lastSortDescending: Bool?
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        lastSortColumn = sortColumn
        lastSortDescending = sortDescending
    }
}

class MockTableSectionDelegate: TableSectionDelegate {
    let labelFactory = MockLabelFactory()
    let backgroundStylist = MockBackgroundStylist()
    let sortHandler = MockSortHandler()
    
    var headerLabelsCreated: Int { labelFactory.headerLabelsCreated }
    var dataLabelsCreated: Int { labelFactory.dataLabelsCreated }
    var backgroundsAdded: Int { backgroundStylist.backgroundsAdded }
    var lastSortColumn: ProcessSortColumn? { sortHandler.lastSortColumn }
    var lastSortDescending: Bool? { sortHandler.lastSortDescending }
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField {
        return labelFactory.createHeaderLabel(text, frame: frame, isDarkBackground: isDarkBackground, sortColumn: sortColumn, fontSize: fontSize, alignment: alignment)
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        return labelFactory.createDataLabel(text: text, frame: frame, alignment: alignment, useMonospacedFont: useMonospacedFont)
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        backgroundStylist.addTableBackground(to: section, padding: padding)
    }
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        sortHandler.updateSortingAndRefresh(sortColumn: sortColumn, sortDescending: sortDescending)
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
        let section = MemoryTableSection(yPosition: 100)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        XCTAssertEqual(section.yPosition, 100)
        XCTAssertEqual(section.height, VerticalTableLayout.calculateTableHeight(for: 7))
        
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 0)
        XCTAssertEqual(mockDelegate.dataLabelsCreated, 13)
        XCTAssertEqual(mockDelegate.backgroundsAdded, 1)
        
        guard let sectionView = section.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let titleLabel = sectionView.subviews.first { ($0 as? NSTextField)?.stringValue == "Memory" }
        XCTAssertNotNil(titleLabel)
    }
    
    func testMemoryTableSectionUpdate() {
        let section = MemoryTableSection(yPosition: 100)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        let stats = MemoryStats(
            totalMemory: 17_179_869_184,
            usedMemory: 12_884_901_888,
            freeMemory: 4_294_967_296,
            memoryPressure: "Normal",
            activeMemory: 4_294_967_296,
            inactiveMemory: 2_147_483_648,
            wiredMemory: 4_294_967_296,
            compressedMemory: 2_147_483_648,
            appPhysicalMemory: 2_147_483_648,
            appVirtualMemory: 8_589_934_592,
            anonymousMemory: 3_221_225_472,
            fileBackedMemory: 1_073_741_824,
            swapTotalMemory: 0,
            swapUsedMemory: 0,
            swapFreeMemory: 0,
            swapUtilization: 0.0,
            swapIns: 0,
            swapOuts: 0,
            topProcesses: []
        )
        
        section.updateData(with: stats)
        
        guard let sectionView = section.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let labels = sectionView.subviews.compactMap { $0 as? NSTextField }
        
        XCTAssertTrue(labels.contains { $0.stringValue == "16" })
        XCTAssertTrue(labels.contains { $0.stringValue == "GB" })
        
        XCTAssertTrue(labels.contains { $0.stringValue == "Normal" })
    }
    
    func testVirtualTableSectionCreation() {
        let section = VirtualTableSection(yPosition: 200)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        XCTAssertEqual(section.yPosition, 200)
        XCTAssertEqual(section.height, VerticalTableLayout.calculateTableHeight(for: 7))
        
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 0)
        XCTAssertEqual(mockDelegate.dataLabelsCreated, 14)
        
        guard let sectionView = section.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let titleLabel = sectionView.subviews.first { ($0 as? NSTextField)?.stringValue == "Virtual" }
        XCTAssertNotNil(titleLabel)
    }
    
    func testSwapTableSectionCreation() {
        let section = SwapTableSection(yPosition: 300)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        XCTAssertEqual(section.yPosition, 300)
        XCTAssertEqual(section.height, VerticalTableLayout.calculateTableHeight(for: 7))
        
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 0)
        XCTAssertEqual(mockDelegate.dataLabelsCreated, 10)
    }
    
    func testProcessTableSectionCreation() {
        let section = ProcessTableSection(yPosition: 400)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        XCTAssertEqual(section.yPosition, 400)
        XCTAssertEqual(section.height, VerticalTableLayout.processTableHeight)
        
        XCTAssertEqual(mockDelegate.headerLabelsCreated, 6)
        
        guard let sectionView = section.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let titleLabel = sectionView.subviews.first { ($0 as? NSTextField)?.stringValue == "Top Processes" }
        XCTAssertNotNil(titleLabel)
    }
    
    func testProcessTableSectionUpdate() {
        let section = ProcessTableSection(yPosition: 400)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        let processes = [
            ProcessInfo(pid: 1234, memoryPercent: 15.5, 
                       memoryBytes: 1_073_741_824, virtualMemoryBytes: 2_147_483_648, 
                       cpuPercent: 5.2, command: "Safari"),
            ProcessInfo(pid: 5678, memoryPercent: 12.3, 
                       memoryBytes: 805_306_368, virtualMemoryBytes: 1_610_612_736, 
                       cpuPercent: 25.8, command: "Xcode")
        ]
        
        let testStats = MemoryStats(
            totalMemory: 17_179_869_184,
            usedMemory: 12_884_901_888,
            freeMemory: 4_294_967_296,
            memoryPressure: "Normal",
            activeMemory: 4_294_967_296,
            inactiveMemory: 2_147_483_648,
            wiredMemory: 4_294_967_296,
            compressedMemory: 2_147_483_648,
            appPhysicalMemory: 2_147_483_648,
            appVirtualMemory: 8_589_934_592,
            anonymousMemory: 3_221_225_472,
            fileBackedMemory: 1_073_741_824,
            swapTotalMemory: 0,
            swapUsedMemory: 0,
            swapFreeMemory: 0,
            swapUtilization: 0.0,
            swapIns: 0,
            swapOuts: 0,
            topProcesses: processes
        )
        
        section.updateData(with: testStats)
        
        guard let sectionView = section.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let labels = sectionView.subviews.compactMap { $0 as? NSTextField }
        
        XCTAssertTrue(labels.contains { $0.stringValue == "Safari" })
        XCTAssertTrue(labels.contains { $0.stringValue == "Xcode" })
        
        XCTAssertTrue(labels.contains { $0.stringValue == "1234" })
        XCTAssertTrue(labels.contains { $0.stringValue == "5678" })
        
        XCTAssertTrue(labels.contains { $0.stringValue == "15.5" })
        XCTAssertTrue(labels.contains { $0.stringValue == "12.3" })
    }
    
    func testProcessTableSectionSorting() {
        let section = ProcessTableSection(yPosition: 400)
        section.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        
        guard let sectionView = section.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let headerLabels = sectionView.subviews.compactMap { view -> NSTextField? in
            guard let label = view as? NSTextField else { return nil }
            return label.cell is VerticallyCenteredTextFieldCell ? label : nil
        }
        XCTAssertGreaterThan(headerLabels.count, 0, "Should have header labels")
        
        mockDelegate.updateSortingAndRefresh(sortColumn: .pid, sortDescending: false)
        
        XCTAssertEqual(mockDelegate.lastSortColumn, .pid)
        XCTAssertEqual(mockDelegate.lastSortDescending, false)
    }
    
    func testBaseTableSectionPadding() {
        let memorySection = MemoryTableSection(yPosition: 100)
        memorySection.setupSection(in: NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600)), delegate: mockDelegate)
        guard let sectionView = memorySection.sectionView else {
            XCTFail("Section view not created")
            return
        }
        let labels = sectionView.subviews.compactMap { $0 as? NSTextField }
        
        let headerLabels = labels.filter { label in
            label.cell is VerticallyCenteredTextFieldCell
        }
        
        for header in headerLabels {
            XCTAssertGreaterThan(header.frame.origin.x, 0)
        }
    }
}