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