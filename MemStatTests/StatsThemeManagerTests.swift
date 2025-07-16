import XCTest
import Cocoa
@testable import MemStat

class StatsThemeManagerTests: XCTestCase {
    
    var themeManager: StatsThemeManager!
    var testView: NSView!
    
    override func setUp() {
        super.setUp()
        themeManager = StatsThemeManager.shared
        testView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    override func tearDown() {
        themeManager = nil
        testView = nil
        super.tearDown()
    }
    
    func testSharedInstance() {
        let instance1 = StatsThemeManager.shared
        let instance2 = StatsThemeManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testApplyTheme() {
        testView.needsDisplay = false
        themeManager.applyTheme(to: testView)
        XCTAssertTrue(testView.needsDisplay)
    }
    
    func testApplyThemeWithSubviews() {
        let subview = NSView(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
        testView.addSubview(subview)
        
        testView.needsDisplay = false
        subview.needsDisplay = false
        
        themeManager.applyTheme(to: testView)
        
        XCTAssertTrue(testView.needsDisplay)
        XCTAssertTrue(subview.needsDisplay)
    }
    
    func testUpdateBorderColors() {
        let borderView = NSView(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
        borderView.layer = CALayer()
        borderView.layer?.borderWidth = 1.0
        testView.addSubview(borderView)
        
        themeManager.applyTheme(to: testView)
        
        XCTAssertNotNil(borderView.layer?.borderColor)
    }
    
    func testUpdateTableBackgrounds() {
        let tableView = NSView(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
        tableView.layer = CALayer()
        testView.addSubview(tableView)
        
        themeManager.applyTheme(to: testView)
        
        XCTAssertNotNil(tableView.layer?.backgroundColor)
    }
    
    func testUpdateTextColors() {
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 50, height: 20))
        testView.addSubview(textField)
        
        themeManager.applyTheme(to: testView)
        
        XCTAssertNotNil(textField.textColor)
    }
}