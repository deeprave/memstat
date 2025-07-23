import XCTest
import Cocoa
@testable import MemStat

class MockLabelFactoryForFieldTests: LabelFactory {
    var headerLabelsCreated = 0
    var dataLabelsCreated = 0
    var lastDataLabelText: String?
    var lastDataLabelFrame: NSRect?
    var lastDataLabelAlignment: NSTextAlignment?
    var lastUseMonospacedFont: Bool?
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment, isSortColumn: Bool) -> NSTextField {
        headerLabelsCreated += 1
        let label = NSTextField(frame: frame)
        label.stringValue = text
        return label
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        dataLabelsCreated += 1
        lastDataLabelText = text
        lastDataLabelFrame = frame
        lastDataLabelAlignment = alignment
        lastUseMonospacedFont = useMonospacedFont
        
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        return label
    }
    
    func createProcessDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        dataLabelsCreated += 1
        lastDataLabelText = text
        lastDataLabelFrame = frame
        lastDataLabelAlignment = alignment
        lastUseMonospacedFont = useMonospacedFont
        
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        return label
    }
    
    func createRowLabel(text: String, frame: NSRect, alignment: NSTextAlignment) -> NSTextField {
        dataLabelsCreated += 1
        lastDataLabelText = text
        lastDataLabelFrame = frame
        lastDataLabelAlignment = alignment
        
        let label = NSTextField(frame: frame)
        label.stringValue = text
        label.alignment = alignment
        return label
    }
}

class TableFieldFactoryTests: XCTestCase {
    
    var factory: TableFieldFactory!
    var mockLabelFactory: MockLabelFactoryForFieldTests!
    var testSection: NSView!
    
    override func setUp() {
        super.setUp()
        mockLabelFactory = MockLabelFactoryForFieldTests()
        factory = TableFieldFactory(labelFactory: mockLabelFactory)
        testSection = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
    }
    
    override func tearDown() {
        factory = nil
        mockLabelFactory = nil
        testSection = nil
        super.tearDown()
    }
    
    func testCreateMetricFieldWithUnits() {
        let fields = factory.createMetricField(
            label: "Total",
            hasUnits: true,
            rowIndex: 0,
            sectionHeight: 200,
            section: testSection
        )
        
        XCTAssertEqual(fields.count, 2)
        XCTAssertEqual(mockLabelFactory.dataLabelsCreated, 3)
        
        let labelSubviews = testSection.subviews.compactMap { $0 as? NSTextField }
        XCTAssertEqual(labelSubviews.count, 3)
        
        XCTAssertTrue(labelSubviews.contains { $0.stringValue == "Total" })
        XCTAssertTrue(labelSubviews.contains { $0.stringValue == "Loading..." })
        XCTAssertTrue(labelSubviews.contains { $0.stringValue == "" })
    }
    
    func testCreateMetricFieldWithoutUnits() {
        let fields = factory.createMetricField(
            label: "Pressure",
            hasUnits: false,
            rowIndex: 1,
            sectionHeight: 200,
            section: testSection
        )
        
        XCTAssertEqual(fields.count, 1)
        XCTAssertEqual(mockLabelFactory.dataLabelsCreated, 2)
        
        let labelSubviews = testSection.subviews.compactMap { $0 as? NSTextField }
        XCTAssertEqual(labelSubviews.count, 2)
        
        XCTAssertTrue(labelSubviews.contains { $0.stringValue == "Pressure" })
        XCTAssertTrue(labelSubviews.contains { $0.stringValue == "Loading..." })
    }
    
    func testCreateMetricFieldPositioning() {
        let rowIndex = 2
        let sectionHeight: CGFloat = 300
        
        _ = factory.createMetricField(
            label: "Active",
            hasUnits: true,
            rowIndex: rowIndex,
            sectionHeight: sectionHeight,
            section: testSection
        )
        
        let expectedY = TableLayoutManager.VerticalTableLayout.rowY(rowIndex: rowIndex, sectionHeight: sectionHeight)
        
        let labelSubviews = testSection.subviews.compactMap { $0 as? NSTextField }
        let activeLabel = labelSubviews.first { $0.stringValue == "Active" }
        
        XCTAssertNotNil(activeLabel)
        XCTAssertEqual(activeLabel?.frame.origin.y, expectedY)
    }
    
    func testCreateMetricFieldCustomLabelWidth() {
        let customWidth: CGFloat = 120
        
        _ = factory.createMetricField(
            label: "Custom",
            hasUnits: true,
            rowIndex: 0,
            sectionHeight: 200,
            section: testSection,
            labelWidth: customWidth
        )
        
        let labelSubviews = testSection.subviews.compactMap { $0 as? NSTextField }
        let customLabel = labelSubviews.first { $0.stringValue == "Custom" }
        
        XCTAssertNotNil(customLabel)
        XCTAssertEqual(customLabel?.frame.width, customWidth)
    }
    
    func testCreateMetricFieldAlignment() {
        _ = factory.createMetricField(
            label: "Util",
            hasUnits: false,
            rowIndex: 0,
            sectionHeight: 200,
            section: testSection
        )
        
        XCTAssertEqual(mockLabelFactory.lastDataLabelAlignment, .right)
        
        mockLabelFactory.dataLabelsCreated = 0
        
        _ = factory.createMetricField(
            label: "Other",
            hasUnits: false,
            rowIndex: 1,
            sectionHeight: 200,
            section: testSection
        )
        
        XCTAssertEqual(mockLabelFactory.lastDataLabelAlignment, .right)
    }
    
    func testCreateMultipleMetricFields() {
        let fields1 = factory.createMetricField(
            label: "Total",
            hasUnits: true,
            rowIndex: 0,
            sectionHeight: 200,
            section: testSection
        )
        
        let fields2 = factory.createMetricField(
            label: "Used",
            hasUnits: true,
            rowIndex: 1,
            sectionHeight: 200,
            section: testSection
        )
        
        let fields3 = factory.createMetricField(
            label: "Free",
            hasUnits: true,
            rowIndex: 2,
            sectionHeight: 200,
            section: testSection
        )
        
        XCTAssertEqual(fields1.count, 2)
        XCTAssertEqual(fields2.count, 2)
        XCTAssertEqual(fields3.count, 2)
        
        XCTAssertEqual(testSection.subviews.count, 9)
    }
}