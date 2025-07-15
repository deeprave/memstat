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
        // Verify status item was created
        XCTAssertNotNil(menuBarController.statusItem)
        
        // Verify status item button exists
        XCTAssertNotNil(menuBarController.statusItem?.button)
        
        // Verify button has an image
        XCTAssertNotNil(menuBarController.statusItem?.button?.image)
        
        // Verify menu is set up
        XCTAssertNotNil(menuBarController.statusItem?.menu)
    }
    
    func testMenuStructure() {
        guard let menu = menuBarController.statusItem?.menu else {
            XCTFail("Menu not found")
            return
        }
        
        // Count menu items
        let menuItems = menu.items
        
        // Find specific menu items
        let statsItem = menuItems.first { $0.title == "Show Stats" }
        let appearanceItem = menuItems.first { $0.title == "Appearance" }
        let launchItem = menuItems.first { $0.title == "Launch at Login" }
        let quitItem = menuItems.first { $0.title == "Quit MemStat" }
        
        // Verify required menu items exist
        XCTAssertNotNil(statsItem, "Show Stats menu item not found")
        XCTAssertNotNil(appearanceItem, "Appearance menu item not found")
        XCTAssertNotNil(launchItem, "Launch at Login menu item not found")
        XCTAssertNotNil(quitItem, "Quit menu item not found")
        
        // Verify quit item has correct key equivalent
        XCTAssertEqual(quitItem?.keyEquivalent, "q")
    }
    
    func testAppearanceSubmenu() {
        guard let menu = menuBarController.statusItem?.menu,
              let appearanceItem = menu.items.first(where: { $0.title == "Appearance" }),
              let submenu = appearanceItem.submenu else {
            XCTFail("Appearance submenu not found")
            return
        }
        
        // Verify appearance options
        let menuTitles = submenu.items.map { $0.title }
        XCTAssertTrue(menuTitles.contains("System"))
        XCTAssertTrue(menuTitles.contains("Light"))
        XCTAssertTrue(menuTitles.contains("Dark"))
        
        // Verify one item is selected by default
        let selectedItems = submenu.items.filter { $0.state == .on }
        XCTAssertEqual(selectedItems.count, 1, "Exactly one appearance should be selected")
    }
    
    func testStatusItemButtonAction() {
        // Verify button has an action
        XCTAssertNotNil(menuBarController.statusItem?.button?.action)
        
        // Verify the target is set
        XCTAssertNotNil(menuBarController.statusItem?.button?.target)
    }
    
    func testToggleStatsWindowBehavior() {
        // Initial state - window should be nil
        XCTAssertNil(menuBarController.statsWindowController)
        
        // Toggle stats window
        menuBarController.toggleStatsWindow(nil)
        
        // Window controller should be created
        XCTAssertNotNil(menuBarController.statsWindowController)
        
        // Toggle again to close
        menuBarController.toggleStatsWindow(nil)
        
        // Window controller should be nil again
        XCTAssertNil(menuBarController.statsWindowController)
    }
    
    func testMenuItemStates() {
        guard let menu = menuBarController.statusItem?.menu else {
            XCTFail("Menu not found")
            return
        }
        
        // Test Launch at Login item
        if let launchItem = menu.items.first(where: { $0.title == "Launch at Login" }) {
            // Should have a valid state
            XCTAssertTrue(launchItem.state == .on || launchItem.state == .off)
            
            // Should have an action
            XCTAssertNotNil(launchItem.action)
        }
    }
    
    func testWindowPositioning() {
        // Get the status item button frame
        guard let button = menuBarController.statusItem?.button,
              let window = button.window else {
            XCTFail("Status item button or window not found")
            return
        }
        
        // Calculate expected position
        let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
        
        // Toggle stats window
        menuBarController.toggleStatsWindow(nil)
        
        // Verify window is positioned correctly
        if let statsWindow = menuBarController.statsWindowController?.window {
            let windowFrame = statsWindow.frame
            
            // Window should be positioned below the menu bar item
            XCTAssertLessThanOrEqual(windowFrame.maxY, buttonFrame.minY)
            
            // Window should be roughly centered on the button
            let buttonCenterX = buttonFrame.midX
            let windowCenterX = windowFrame.midX
            XCTAssertLessThanOrEqual(abs(buttonCenterX - windowCenterX), 200)
        }
    }
    
    func testMemoryLeaks() {
        // Create and destroy window controller multiple times
        for _ in 0..<5 {
            menuBarController.toggleStatsWindow(nil)
            menuBarController.toggleStatsWindow(nil)
        }
        
        // Verify no window controller remains
        XCTAssertNil(menuBarController.statsWindowController)
    }
}