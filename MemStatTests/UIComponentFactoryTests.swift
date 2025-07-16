import XCTest
import Cocoa
@testable import MemStat

class UIComponentFactoryTests: XCTestCase {
    
    var factory: UIComponentFactory!
    var testView: NSView!
    
    override func setUp() {
        super.setUp()
        factory = UIComponentFactory()
        testView = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    }
    
    override func tearDown() {
        factory = nil
        testView = nil
        super.tearDown()
    }
    
    func testCreateHeaderLabel() {
        let text = "Test Header"
        let frame = NSRect(x: 10, y: 10, width: 100, height: 20)
        let label = factory.createHeaderLabel(text, frame: frame, isDarkBackground: false, sortColumn: nil, fontSize: 12.0, alignment: .center)
        
        XCTAssertEqual(label.stringValue, text)
        XCTAssertEqual(label.frame, frame)
        XCTAssertEqual(label.alignment, .center)
        XCTAssertTrue(label.cell is VerticallyCenteredTextFieldCell)
    }
    
    func testCreateHeaderLabelWithSortColumn() {
        let text = "Memory"
        let frame = NSRect(x: 10, y: 10, width: 100, height: 20)
        let label = factory.createHeaderLabel(text, frame: frame, isDarkBackground: false, sortColumn: .memoryPercent, fontSize: 12.0, alignment: .center)
        
        XCTAssertEqual(label.stringValue, text)
        XCTAssertNotNil(label.cell as? VerticallyCenteredTextFieldCell)
    }
    
    func testCreateDataLabel() {
        let text = "Test Data"
        let frame = NSRect(x: 20, y: 20, width: 80, height: 18)
        let label = factory.createDataLabel(text: text, frame: frame, alignment: .right, useMonospacedFont: false)
        
        XCTAssertEqual(label.stringValue, text)
        XCTAssertEqual(label.frame, frame)
        XCTAssertEqual(label.alignment, .right)
        XCTAssertFalse(label.isEditable)
        XCTAssertFalse(label.isSelectable)
        XCTAssertFalse(label.drawsBackground)
        XCTAssertTrue(label.isBordered == false)
    }
    
    func testCreateDataLabelWithMonospacedFont() {
        let text = "12345"
        let frame = NSRect(x: 20, y: 20, width: 80, height: 18)
        let label = factory.createDataLabel(text: text, frame: frame, alignment: .right, useMonospacedFont: true)
        
        XCTAssertEqual(label.stringValue, text)
        XCTAssertNotNil(label.font)
    }
    
    func testAddTableBackground() {
        let section = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        testView.addSubview(section)
        
        let initialSubviewCount = section.subviews.count
        factory.addTableBackground(to: section, padding: 5.0)
        
        XCTAssertEqual(section.subviews.count, initialSubviewCount + 1)
        
        let backgroundView = section.subviews.last
        XCTAssertNotNil(backgroundView)
        XCTAssertNotNil(backgroundView?.layer)
        XCTAssertNotNil(backgroundView?.layer?.backgroundColor)
    }
    
    func testAddTableBackgroundWithPadding() {
        let section = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        testView.addSubview(section)
        
        let padding: CGFloat = 10.0
        factory.addTableBackground(to: section, padding: padding)
        
        let backgroundView = section.subviews.last
        XCTAssertNotNil(backgroundView)
        
        let expectedFrame = NSRect(
            x: padding,
            y: padding,
            width: section.frame.width - 2 * padding,
            height: section.frame.height - 2 * padding
        )
        XCTAssertEqual(backgroundView?.frame, expectedFrame)
    }
    
    func testLabelFactoryProtocolConformance() {
        XCTAssertTrue(factory is LabelFactory)
    }
    
    func testBackgroundStylistProtocolConformance() {
        XCTAssertTrue(factory is BackgroundStylist)
    }
}