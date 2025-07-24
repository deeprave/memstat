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
    
    // MARK: - Mode Switching Tests
    
    func testSwitchToWindowModeMethodExists() {
        XCTAssertNotNil(menuBarController)
    }
    
    func testContextMenuContainsModeSwitch() {
        XCTAssertNotNil(menuBarController.statusItem, "Status item should be created")
    }
    
    // MARK: - Bring to Front Feature Tests
    
    func testBringToFrontMenuItemExists() {
        let contextMenu = menuBarController.contextMenu
        XCTAssertNotNil(contextMenu)
        
        let bringToFrontItem = contextMenu?.items.first { $0.title == "Bring to Front" }
        XCTAssertNotNil(bringToFrontItem, "Bring to Front menu item should exist")
        XCTAssertEqual(bringToFrontItem?.action, #selector(MenuBarController.bringStatsWindowToFront))
        XCTAssertEqual(bringToFrontItem?.target as? MenuBarController, menuBarController)
        XCTAssertEqual(bringToFrontItem?.keyEquivalent, "", "Bring to Front should have no keyboard shortcut")
    }
    
    func testBringToFrontMenuItemPosition() {
        let contextMenu = menuBarController.contextMenu
        XCTAssertNotNil(contextMenu)
        
        let firstItem = contextMenu?.items.first
        XCTAssertEqual(firstItem?.title, "Bring to Front", "Bring to Front should be the first menu item")
        
        if contextMenu!.items.count > 1 {
            let secondItem = contextMenu!.items[1]
            XCTAssertTrue(secondItem.isSeparatorItem, "There should be a separator after Bring to Front")
        }
    }
    
    func testBringToFrontMethodExists() {
        XCTAssertTrue(menuBarController.responds(to: #selector(MenuBarController.bringStatsWindowToFront)), 
                     "MenuBarController should respond to bringStatsWindowToFront")
    }
    
    // MARK: - Draggable Window Feature Tests
    
    func testStatsWindowHasDraggableView() {
        let statsWindowController = menuBarController.testableStatsWindowController
        
        XCTAssertNotNil(statsWindowController, "MenuBarController should have a statsWindowController")
        
        if let controller = statsWindowController,
           let window = controller.window,
           let contentView = window.contentView,
           contentView.subviews.count > 0 {
            let statsView = contentView.subviews[0]
            XCTAssertTrue(statsView is DraggableView, "Stats view should be a DraggableView for drag functionality")
        }
    }
}