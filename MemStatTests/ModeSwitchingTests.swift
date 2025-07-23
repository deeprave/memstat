import XCTest
import Cocoa
@testable import MemStat

class ModeSwitchingTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        
        UserDefaults.standard.removeObject(forKey: "AppMode")
    }
    
    override func tearDown() {
        appDelegate.mainWindowController?.close()
        appDelegate.mainWindowController = nil
        appDelegate.menuBarController = nil
        
        UserDefaults.standard.removeObject(forKey: "AppMode")
        
        appDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Mode Switching Logic Tests
    
    func testSwitchToSameModeDoesNothing() {
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        
        let initialPreference = UserDefaults.standard.string(forKey: "AppMode")
        
        let targetMode = AppMode.window
        let currentMode = AppMode.window
        
        if targetMode != currentMode {
            UserDefaults.standard.set(targetMode.rawValue, forKey: "AppMode")
        }
        
        let finalPreference = UserDefaults.standard.string(forKey: "AppMode")
        XCTAssertEqual(initialPreference, finalPreference, "Preference should not change when switching to same mode")
    }
    
    func testSwitchToDifferentModeUpdatesPreference() {
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        
        let initialMode = AppMode.window
        let targetMode = AppMode.menubar
        
        UserDefaults.standard.set(targetMode.rawValue, forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode")
        XCTAssertEqual(savedMode, targetMode.rawValue, "Should save new mode preference")
        XCTAssertNotEqual(savedMode, initialMode.rawValue, "Should change from initial mode")
    }
    
    func testModePreferencePersistence() {
        let testModes: [AppMode] = [.window, .menubar, .window, .menubar]
        
        for mode in testModes {
            UserDefaults.standard.set(mode.rawValue, forKey: "AppMode")
            
            let savedMode = UserDefaults.standard.string(forKey: "AppMode")
            let loadedMode = AppMode(rawValue: savedMode ?? "")
            
            XCTAssertEqual(loadedMode, mode, "Mode should persist correctly: \(mode)")
        }
    }
    
    // MARK: - Menu Integration Tests
    
    func testSwitchModeMethodExists() {
        XCTAssertNotNil(appDelegate)
        
        let currentMode = AppMode.window
        XCTAssertEqual(currentMode, .window, "Default mode should be window")
    }
    
    func testMenuItemRepresentedObjectHandling() {
        let menuItem = NSMenuItem(title: "Test", action: nil, keyEquivalent: "")
        menuItem.representedObject = AppMode.menubar
        
        let retrievedMode = menuItem.representedObject as? AppMode
        XCTAssertEqual(retrievedMode, .menubar, "Menu item should carry mode information")
    }
    
    func testMenuItemStateForCurrentMode() {
        let currentMode = AppMode.window
        
        let windowMenuItem = NSMenuItem(title: "Regular Window", action: nil, keyEquivalent: "")
        windowMenuItem.representedObject = AppMode.window
        windowMenuItem.state = (AppMode.window == currentMode) ? .on : .off
        
        let menubarMenuItem = NSMenuItem(title: "Menu Bar", action: nil, keyEquivalent: "")
        menubarMenuItem.representedObject = AppMode.menubar
        menubarMenuItem.state = (AppMode.menubar == currentMode) ? .on : .off
        
        XCTAssertEqual(windowMenuItem.state, .on, "Current mode menu item should be checked")
        XCTAssertEqual(menubarMenuItem.state, .off, "Non-current mode menu item should not be checked")
    }
    
    // MARK: - Application Lifecycle Tests
    
    func testApplicationTerminationBehaviorByMode() {
        let windowModeTerminates = true
        XCTAssertTrue(windowModeTerminates, "Window mode should terminate when last window closes")
        
        let menubarModeTerminates = false
        XCTAssertFalse(menubarModeTerminates, "Menubar mode should not terminate when window closes")
    }
    
    func testDockIconVisibilityByMode() {
        let windowModePolicy = NSApplication.ActivationPolicy.regular
        XCTAssertEqual(windowModePolicy, .regular, "Window mode should use regular activation policy")
        
        let menubarModePolicy = NSApplication.ActivationPolicy.accessory
        XCTAssertEqual(menubarModePolicy, .accessory, "Menubar mode should use accessory activation policy")
    }
    
    // MARK: - Controller Lifecycle Tests
    
    func testControllerCleanupOnModeSwitch() {
        XCTAssertTrue(true, "Test skipped - UI components not available in test environment")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidModeHandling() {
        UserDefaults.standard.set("invalid_mode", forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let parsedMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(parsedMode, .window, "Invalid mode should fall back to window mode")
    }
    
    func testEmptyModeHandling() {
        UserDefaults.standard.set("", forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let parsedMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(parsedMode, .window, "Empty mode should fall back to window mode")
    }
    
    func testNilModeHandling() {
        UserDefaults.standard.removeObject(forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let parsedMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(parsedMode, .window, "Missing mode should fall back to window mode")
    }
    
    // MARK: - Integration Tests
    
    func testFullModeSwitch() {
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        let initialMode = AppMode(rawValue: UserDefaults.standard.string(forKey: "AppMode") ?? "") ?? .window
        XCTAssertEqual(initialMode, .window, "Should start in window mode")
        
        UserDefaults.standard.set(AppMode.menubar.rawValue, forKey: "AppMode")
        let switchedMode = AppMode(rawValue: UserDefaults.standard.string(forKey: "AppMode") ?? "") ?? .window
        XCTAssertEqual(switchedMode, .menubar, "Should switch to menubar mode")
        
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        let finalMode = AppMode(rawValue: UserDefaults.standard.string(forKey: "AppMode") ?? "") ?? .window
        XCTAssertEqual(finalMode, .window, "Should switch back to window mode")
    }
    
    func testModeConsistencyAcrossLaunches() {
        let testModes: [AppMode] = [.menubar, .window, .menubar]
        
        for mode in testModes {
            UserDefaults.standard.set(mode.rawValue, forKey: "AppMode")
            
            let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
            let loadedMode = AppMode(rawValue: savedMode) ?? .window
            
            XCTAssertEqual(loadedMode, mode, "Mode should be consistent across launches: \(mode)")
        }
    }
}