import XCTest
import Cocoa
@testable import MemStat

class MenuBarControllerTests: XCTestCase {
    
    var menuBarController: MenuBarController!
    
    override func setUp() {
        super.setUp()
        menuBarController = MenuBarController()
    }
    
    override func tearDown() {
        menuBarController = nil
        super.tearDown()
    }
    
    func testMenuBarControllerInitialization() {
        XCTAssertNotNil(menuBarController.statusItem)
        XCTAssertNotNil(menuBarController.statusItem?.button)
        XCTAssertNotNil(menuBarController.statusItem?.button?.image)
    }
    
    func testStatusItemButtonSetup() {
        guard let button = menuBarController.statusItem?.button else {
            XCTFail("Status item button not found")
            return
        }
        
        XCTAssertNotNil(button.action)
        XCTAssertEqual(button.target as? MenuBarController, menuBarController)
    }
    
    func testButtonImageSetup() {
        guard let button = menuBarController.statusItem?.button,
              let image = button.image else {
            XCTFail("Status item button or image not found")
            return
        }
        
        XCTAssertFalse(image.size.width == 0)
        XCTAssertFalse(image.size.height == 0)
        XCTAssertTrue(image.isTemplate)
    }
    
    func testButtonActionExists() {
        guard let button = menuBarController.statusItem?.button else {
            XCTFail("Status item button not found")
            return
        }
        
        XCTAssertNotNil(button.action)
    }
    
    func testMenuBarItemLength() {
        XCTAssertEqual(menuBarController.statusItem?.length, 28)
    }
    
    func testContextMenuAvailability() {
        XCTAssertNil(menuBarController.statusItem?.menu)
    }
    
    func testControllerMemoryManagement() {
        let controller1 = MenuBarController()
        let controller2 = MenuBarController()
        
        XCTAssertNotNil(controller1.statusItem)
        XCTAssertNotNil(controller2.statusItem)
        
        XCTAssertNotEqual(controller1.statusItem, controller2.statusItem)
    }
    
    func testButtonClickSimulation() {
        guard let button = menuBarController.statusItem?.button else {
            XCTFail("Status item button not found")
            return
        }
        
        XCTAssertNotNil(button.action, "Button should have an action")
        XCTAssertNotNil(button.target, "Button should have a target")
        XCTAssertTrue(button.target === menuBarController, "Button target should be the menu bar controller")
    }
    
    func testStatusItemPersistence() {
        let initialStatusItem = menuBarController.statusItem
        XCTAssertNotNil(initialStatusItem)
        
        XCTAssertEqual(menuBarController.statusItem, initialStatusItem)
        let secondAccess = menuBarController.statusItem
        XCTAssertEqual(secondAccess, initialStatusItem)
    }
    
    func testButtonImageTemplate() {
        guard let button = menuBarController.statusItem?.button,
              let image = button.image else {
            XCTFail("Status item button or image not found")
            return
        }
        
        XCTAssertTrue(image.isTemplate, "Menu bar icon should be a template image")
    }
}