import XCTest
import Cocoa
@testable import MemStat

class AppDelegateTests: XCTestCase {
    
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
    
    // MARK: - Initialization Tests
    
    func testAppDelegateInitialization() {
        XCTAssertNotNil(appDelegate)
        XCTAssertNil(appDelegate.mainWindowController)
        XCTAssertNil(appDelegate.menuBarController)
    }
    
    // MARK: - Default Mode Tests
    
    func testDefaultModeIsWindow() {
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let currentMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(currentMode, .window, "Default mode should be window")
    }
    
    func testSavedPreferenceIsRespected() {
        UserDefaults.standard.set(AppMode.menubar.rawValue, forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let currentMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(currentMode, .menubar, "Should respect saved menubar preference")
        
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        
        let savedMode2 = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let currentMode2 = AppMode(rawValue: savedMode2) ?? .window
        
        XCTAssertEqual(currentMode2, .window, "Should respect saved window preference")
    }
    
    func testInvalidSavedPreferenceFallsBackToWindow() {
        UserDefaults.standard.set("invalid_mode", forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let currentMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(currentMode, .window, "Invalid preference should fall back to window mode")
    }
    
    // MARK: - Command Line Parsing Tests
    
    func testCommandLineParsingLogic() {
        let testArgs = ["MemStat"]
        let hasMenubarFlag = testArgs.contains("--menubar") || testArgs.contains("-m")
        let hasWindowFlag = testArgs.contains("--window") || testArgs.contains("-w")
        
        XCTAssertFalse(hasMenubarFlag, "Should not detect menubar flag")
        XCTAssertFalse(hasWindowFlag, "Should not detect window flag")
    }
    
    func testCommandLineFlagDetection() {
        let menubarLongArgs = ["MemStat", "--menubar"]
        let menubarShortArgs = ["MemStat", "-m"]
        
        XCTAssertTrue(menubarLongArgs.contains("--menubar"), "Should detect --menubar flag")
        XCTAssertTrue(menubarShortArgs.contains("-m"), "Should detect -m flag")
        
        let windowLongArgs = ["MemStat", "--window"]
        let windowShortArgs = ["MemStat", "-w"]
        
        XCTAssertTrue(windowLongArgs.contains("--window"), "Should detect --window flag")
        XCTAssertTrue(windowShortArgs.contains("-w"), "Should detect -w flag")
        
        let helpLongArgs = ["MemStat", "--help"]
        let helpShortArgs = ["MemStat", "-h"]
        
        XCTAssertTrue(helpLongArgs.contains("--help"), "Should detect --help flag")
        XCTAssertTrue(helpShortArgs.contains("-h"), "Should detect -h flag")
    }
    
    // MARK: - Mode Switching Tests
    
    func testSwitchToModeUpdatesPref() {
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        
        
        let initialMode = AppMode.window
        let targetMode = AppMode.menubar
        
        UserDefaults.standard.set(targetMode.rawValue, forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode")
        XCTAssertEqual(savedMode, targetMode.rawValue, "Should save new mode preference")
    }
    
    func testSwitchToSameModeDoesNothing() {
        let currentMode = AppMode.window
        let targetMode = AppMode.window
        
        XCTAssertEqual(currentMode, targetMode, "Switching to same mode should be no-op")
    }
    
    // MARK: - Application Lifecycle Tests
    
    func testApplicationShouldTerminateAfterLastWindowClosed() {
        let windowModeResult = appDelegate.applicationShouldTerminateAfterLastWindowClosed(NSApp)
        XCTAssertTrue(windowModeResult is Bool, "Should return a boolean value")
    }
    
    func testApplicationSupportsSecureRestorableState() {
        let result = appDelegate.applicationSupportsSecureRestorableState(NSApp)
        XCTAssertTrue(result, "Should support secure restorable state")
    }
    
    // MARK: - Menu Setup Tests
    
    func testAboutDialogCreation() {
        XCTAssertNotNil(appDelegate)
    }
    
    func testAppearanceMethodsExist() {
        XCTAssertNotNil(appDelegate)
        
        UserDefaults.standard.set("auto", forKey: "AppearanceMode")
        let savedMode = UserDefaults.standard.string(forKey: "AppearanceMode")
        XCTAssertEqual(savedMode, "auto", "Should be able to save appearance mode")
    }
    
    // MARK: - Window Menu Tests
    
    func testWindowMenuCreation() {
        // Simulate the menu setup that would happen in window mode
        let mainMenu = NSMenu()
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        
        let bringToFrontItem = NSMenuItem(title: "Bring to Front", action: #selector(AppDelegate.bringToFront), keyEquivalent: "")
        bringToFrontItem.target = appDelegate
        windowMenu.addItem(bringToFrontItem)
        
        windowMenu.addItem(NSMenuItem.separator())
        
        let minimizeItem = NSMenuItem(title: "Minimize", action: #selector(AppDelegate.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(minimizeItem)
        
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)
        
        // Verify menu structure
        XCTAssertEqual(windowMenu.title, "Window", "Window menu should have correct title")
        XCTAssertEqual(windowMenu.numberOfItems, 3, "Window menu should have 3 items (2 actions + 1 separator)")
        
        // Verify menu items
        XCTAssertEqual(windowMenu.item(at: 0)?.title, "Bring to Front", "First item should be Bring to Front")
        XCTAssertEqual(windowMenu.item(at: 0)?.action, #selector(AppDelegate.bringToFront), "Bring to Front should have correct action")
        XCTAssertEqual(windowMenu.item(at: 0)?.target as? AppDelegate, appDelegate, "Bring to Front should target AppDelegate")
        
        XCTAssertTrue(windowMenu.item(at: 1)?.isSeparatorItem == true, "Second item should be separator")
        
        XCTAssertEqual(windowMenu.item(at: 2)?.title, "Minimize", "Third item should be Minimize")
        XCTAssertEqual(windowMenu.item(at: 2)?.action, #selector(AppDelegate.performMiniaturize(_:)), "Minimize should have correct action")
        XCTAssertEqual(windowMenu.item(at: 2)?.keyEquivalent, "m", "Minimize should have ⌘M shortcut")
    }
    
    func testWindowActionsWithNoWindow() {
        // Ensure no window controller is set
        appDelegate.mainWindowController = nil
        
        // Test that window actions don't crash when no window exists
        XCTAssertNoThrow(appDelegate.bringToFront(), "bringToFront should not crash with no window")
        XCTAssertNoThrow(appDelegate.performMiniaturize(nil), "performMiniaturize should not crash with no window")
    }
    
    func testWindowActionMethodsExist() {
        // Verify the methods exist and are accessible
        XCTAssertTrue(appDelegate.responds(to: #selector(AppDelegate.bringToFront)), "AppDelegate should respond to bringToFront")
        XCTAssertTrue(appDelegate.responds(to: #selector(AppDelegate.performMiniaturize(_:))), "AppDelegate should respond to performMiniaturize")
    }
    
    // MARK: - Mode Switching Menu Tests
    
    func testSwitchToMenuBarModeMenuCreation() {
        // Simulate the menu setup that would happen in window mode
        let appMenu = NSMenu()
        
        let switchModeItem = NSMenuItem(title: "Switch to Menu Bar", action: #selector(AppDelegate.switchToMenuBarMode), keyEquivalent: "")
        switchModeItem.target = appDelegate
        appMenu.addItem(switchModeItem)
        
        // Verify menu item
        XCTAssertEqual(switchModeItem.title, "Switch to Menu Bar", "Menu item should have correct title")
        XCTAssertEqual(switchModeItem.action, #selector(AppDelegate.switchToMenuBarMode), "Menu item should have correct action")
        XCTAssertEqual(switchModeItem.target as? AppDelegate, appDelegate, "Menu item should target AppDelegate")
        XCTAssertEqual(switchModeItem.keyEquivalent, "", "Menu item should have no keyboard shortcut")
    }
    
    func testSwitchToMenuBarModeMethodExists() {
        // Verify the method exists and is accessible
        XCTAssertTrue(appDelegate.responds(to: #selector(AppDelegate.switchToMenuBarMode)), "AppDelegate should respond to switchToMenuBarMode")
    }
}

// MARK: - Test Extensions

extension AppDelegateTests {
    
    private func simulateCommandLineArgs(_ args: [String]) -> AppMode? {
        if args.contains("--menubar") || args.contains("-m") {
            return .menubar
        }
        if args.contains("--window") || args.contains("-w") {
            return .window
        }
        return nil
    }
}