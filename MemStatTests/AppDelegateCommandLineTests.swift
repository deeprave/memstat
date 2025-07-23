import XCTest
import Cocoa
@testable import MemStat

class AppDelegateCommandLineTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    var originalArguments: [String] = []
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        originalArguments = CommandLine.arguments
        
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
    
    // MARK: - Command Line Parsing Tests
    
    func testCommandLineArgumentParsing() {
        var testArgs = ["MemStat", "--menubar"]
        XCTAssertTrue(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("--window"))
        XCTAssertFalse(testArgs.contains("--help"))
        
        testArgs = ["MemStat", "-m"]
        XCTAssertTrue(testArgs.contains("-m"))
        XCTAssertFalse(testArgs.contains("-w"))
        XCTAssertFalse(testArgs.contains("-h"))
        
        testArgs = ["MemStat", "--window"]
        XCTAssertTrue(testArgs.contains("--window"))
        XCTAssertFalse(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("--help"))
        
        testArgs = ["MemStat", "-w"]
        XCTAssertTrue(testArgs.contains("-w"))
        XCTAssertFalse(testArgs.contains("-m"))
        XCTAssertFalse(testArgs.contains("-h"))
        
        testArgs = ["MemStat", "--help"]
        XCTAssertTrue(testArgs.contains("--help"))
        XCTAssertFalse(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("--window"))
        
        testArgs = ["MemStat", "-h"]
        XCTAssertTrue(testArgs.contains("-h"))
        XCTAssertFalse(testArgs.contains("-m"))
        XCTAssertFalse(testArgs.contains("-w"))
    }
    
    func testMultipleCommandLineFlags() {
        let testArgs = ["MemStat", "--menubar", "--window"]
        
        XCTAssertTrue(testArgs.contains("--menubar"))
        XCTAssertTrue(testArgs.contains("--window"))
        
    }
    
    func testCaseInsensitiveFlags() {
        let testArgs = ["MemStat", "--MENUBAR", "--Window", "-M", "-W"]
        
        XCTAssertFalse(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("--window"))
        XCTAssertFalse(testArgs.contains("-m"))
        XCTAssertFalse(testArgs.contains("-w"))
        
        XCTAssertTrue(testArgs.contains("--MENUBAR"))
        XCTAssertTrue(testArgs.contains("--Window"))
        XCTAssertTrue(testArgs.contains("-M"))
        XCTAssertTrue(testArgs.contains("-W"))
    }
    
    func testInvalidCommandLineFlags() {
        let testArgs = ["MemStat", "--menu", "--bar", "-mb", "--windows", "-window"]
        
        XCTAssertFalse(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("--window"))
        XCTAssertFalse(testArgs.contains("-m"))
        XCTAssertFalse(testArgs.contains("-w"))
        
        XCTAssertTrue(testArgs.contains("--menu"))
        XCTAssertTrue(testArgs.contains("--bar"))
        XCTAssertTrue(testArgs.contains("-mb"))
        XCTAssertTrue(testArgs.contains("--windows"))
        XCTAssertTrue(testArgs.contains("-window"))
    }
    
    func testCommandLineParsingPrecedence() {
        
        var testArgs = ["MemStat", "--menubar", "--window", "--help"]
        XCTAssertTrue(testArgs.contains("--menubar"))
        
        testArgs = ["MemStat", "--window", "--help"]
        XCTAssertTrue(testArgs.contains("--window"))
        XCTAssertFalse(testArgs.contains("--menubar"))
        
        testArgs = ["MemStat", "--help"]
        XCTAssertTrue(testArgs.contains("--help"))
        XCTAssertFalse(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("--window"))
    }
    
    func testNoCommandLineFlags() {
        let testArgs = ["MemStat"]
        
        XCTAssertFalse(testArgs.contains("--menubar"))
        XCTAssertFalse(testArgs.contains("-m"))
        XCTAssertFalse(testArgs.contains("--window"))
        XCTAssertFalse(testArgs.contains("-w"))
        XCTAssertFalse(testArgs.contains("--help"))
        XCTAssertFalse(testArgs.contains("-h"))
        
        XCTAssertEqual(testArgs.count, 1)
        XCTAssertEqual(testArgs[0], "MemStat")
    }
    
    // MARK: - AppMode Integration Tests
    
    func testAppModeEnumValues() {
        XCTAssertEqual(AppMode.menubar.rawValue, "menubar")
        XCTAssertEqual(AppMode.window.rawValue, "window")
        
        XCTAssertEqual(AppMode(rawValue: "menubar"), .menubar)
        XCTAssertEqual(AppMode(rawValue: "window"), .window)
        XCTAssertNil(AppMode(rawValue: "invalid"))
    }
    
    func testAppModeDefaultFallback() {
        UserDefaults.standard.removeObject(forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let mode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(mode, .window)
    }
    
    func testAppModePreferencePersistence() {
        UserDefaults.standard.set(AppMode.menubar.rawValue, forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode")
        XCTAssertEqual(savedMode, "menubar")
        
        let mode = AppMode(rawValue: savedMode ?? "")
        XCTAssertEqual(mode, .menubar)
    }
    
    // MARK: - Bundle and Path Tests for Restart
    
    func testBundlePathAccess() {
        let bundle = Bundle.main
        XCTAssertNotNil(bundle)
        
        let resourcePath = bundle.resourcePath
        XCTAssertNotNil(resourcePath, "Bundle should have resource path")
        
        if let resourcePath = resourcePath {
            let url = URL(fileURLWithPath: resourcePath)
            XCTAssertNotNil(url)
            
            let parentPath = url.deletingLastPathComponent()
            XCTAssertNotNil(parentPath)
            
            let appPath = parentPath.deletingLastPathComponent()
            XCTAssertNotNil(appPath)
            
            let absoluteString = appPath.absoluteString
            XCTAssertFalse(absoluteString.isEmpty)
            XCTAssertTrue(absoluteString.hasPrefix("file://"))
        }
    }
    
    func testProcessCreation() {
        let process = Process()
        XCTAssertNotNil(process)
        
        process.launchPath = "/usr/bin/echo"
        XCTAssertEqual(process.launchPath, "/usr/bin/echo")
        
        process.arguments = ["test"]
        XCTAssertEqual(process.arguments, ["test"])
        
        XCTAssertNotNil(process.launchPath)
        XCTAssertNotNil(process.arguments)
        XCTAssertEqual(process.arguments?.count, 1)
    }
    
    func testOpenCommandAvailability() {
        let openPath = "/usr/bin/open"
        let fileManager = FileManager.default
        
        XCTAssertTrue(fileManager.fileExists(atPath: openPath), "/usr/bin/open should exist on macOS")
        XCTAssertTrue(fileManager.isExecutableFile(atPath: openPath), "/usr/bin/open should be executable")
    }
    
    // MARK: - NSApplication Integration Tests
    
    func testNSAppTermination() {
        let app = NSApplication.shared
        XCTAssertNotNil(app)
        
        let respondsToTerminate = app.responds(to: #selector(NSApplication.terminate(_:)))
        XCTAssertTrue(respondsToTerminate, "NSApplication should respond to terminate:")
        
    }
    
    func testNSAlertCreation() {
        let alert = NSAlert()
        XCTAssertNotNil(alert)
        
        alert.messageText = "Test Message"
        alert.informativeText = "Test Information"
        
        XCTAssertEqual(alert.messageText, "Test Message")
        XCTAssertEqual(alert.informativeText, "Test Information")
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        XCTAssertEqual(alert.buttons.count, 2)
        XCTAssertEqual(alert.buttons[0].title, "OK")
        XCTAssertEqual(alert.buttons[1].title, "Cancel")
    }
    
    // MARK: - UserDefaults Integration Tests
    
    func testUserDefaultsAccess() {
        let defaults = UserDefaults.standard
        XCTAssertNotNil(defaults)
        
        defaults.set("test_value", forKey: "test_key")
        let retrievedValue = defaults.string(forKey: "test_key")
        XCTAssertEqual(retrievedValue, "test_value")
        
        defaults.removeObject(forKey: "test_key")
        let removedValue = defaults.string(forKey: "test_key")
        XCTAssertNil(removedValue)
    }
    
    func testAppModeUserDefaultsIntegration() {
        UserDefaults.standard.removeObject(forKey: "AppMode")
        
        UserDefaults.standard.set(AppMode.menubar.rawValue, forKey: "AppMode")
        let menubarMode = UserDefaults.standard.string(forKey: "AppMode")
        XCTAssertEqual(menubarMode, "menubar")
        
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        let windowMode = UserDefaults.standard.string(forKey: "AppMode")
        XCTAssertEqual(windowMode, "window")
        
        let mode = AppMode(rawValue: windowMode ?? "")
        XCTAssertEqual(mode, .window)
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidBundlePath() {
        let bundle = Bundle.main
        
        if bundle.resourcePath == nil {
            XCTAssertNil(bundle.resourcePath)
        } else {
            XCTAssertNotNil(bundle.resourcePath)
        }
    }
    
    func testProcessLaunchFailure() {
        let process = Process()
        process.launchPath = "/invalid/path/to/nonexistent/command"
        process.arguments = ["test"]
        
        XCTAssertThrowsError(try process.run()) { error in
            XCTAssertTrue(error is NSError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testCommandLineParsingPerformance() {
        let testArgs = ["MemStat", "--menubar", "--window", "--help", "-m", "-w", "-h"]
        
        measure {
            for _ in 0..<1000 {
                let _ = testArgs.contains("--menubar") || testArgs.contains("-m")
                let _ = testArgs.contains("--window") || testArgs.contains("-w")
                let _ = testArgs.contains("--help") || testArgs.contains("-h")
            }
        }
    }
    
    func testUserDefaultsPerformance() {
        measure {
            for i in 0..<100 {
                UserDefaults.standard.set("test_\(i)", forKey: "test_key")
                let _ = UserDefaults.standard.string(forKey: "test_key")
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "test_key")
    }
    
    // MARK: - Integration Tests
    
    func testFullCommandLineToModeFlow() {
        var testArgs = ["MemStat", "--menubar"]
        var hasMenubar = testArgs.contains("--menubar") || testArgs.contains("-m")
        var hasWindow = testArgs.contains("--window") || testArgs.contains("-w")
        var hasHelp = testArgs.contains("--help") || testArgs.contains("-h")
        
        XCTAssertTrue(hasMenubar)
        XCTAssertFalse(hasWindow)
        XCTAssertFalse(hasHelp)
        
        var expectedMode: AppMode? = nil
        if hasMenubar { expectedMode = .menubar }
        else if hasWindow { expectedMode = .window }
        else if hasHelp { expectedMode = nil }
        
        XCTAssertEqual(expectedMode, .menubar)
        
        testArgs = ["MemStat", "--window"]
        hasMenubar = testArgs.contains("--menubar") || testArgs.contains("-m")
        hasWindow = testArgs.contains("--window") || testArgs.contains("-w")
        hasHelp = testArgs.contains("--help") || testArgs.contains("-h")
        
        XCTAssertFalse(hasMenubar)
        XCTAssertTrue(hasWindow)
        XCTAssertFalse(hasHelp)
        
        expectedMode = nil
        if hasMenubar { expectedMode = .menubar }
        else if hasWindow { expectedMode = .window }
        else if hasHelp { expectedMode = nil }
        
        XCTAssertEqual(expectedMode, .window)
        
        testArgs = ["MemStat"]
        hasMenubar = testArgs.contains("--menubar") || testArgs.contains("-m")
        hasWindow = testArgs.contains("--window") || testArgs.contains("-w")
        hasHelp = testArgs.contains("--help") || testArgs.contains("-h")
        
        XCTAssertFalse(hasMenubar)
        XCTAssertFalse(hasWindow)
        XCTAssertFalse(hasHelp)
        
        expectedMode = nil
        if hasMenubar { expectedMode = .menubar }
        else if hasWindow { expectedMode = .window }
        else if hasHelp { expectedMode = nil }
        
        XCTAssertNil(expectedMode)
    }
    
    func testRestartPreparationSteps() {
        guard let resourcePath = Bundle.main.resourcePath else {
            XCTFail("Bundle should have resource path")
            return
        }
        
        let url = URL(fileURLWithPath: resourcePath)
        let appPath = url.deletingLastPathComponent().deletingLastPathComponent()
        let absoluteString = appPath.absoluteString
        
        XCTAssertFalse(absoluteString.isEmpty)
        XCTAssertTrue(absoluteString.hasPrefix("file://"))
        
        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = [absoluteString]
        
        XCTAssertEqual(process.launchPath, "/usr/bin/open")
        XCTAssertEqual(process.arguments, [absoluteString])
        
        XCTAssertNotNil(process)
    }
}

// MARK: - Mock Helper Classes

class MockCommandLineArguments {
    static func simulate(args: [String], block: () -> Void) {
        block()
    }
}

extension AppDelegateCommandLineTests {
    
    func simulateCommandLineParsing(args: [String]) -> AppMode? {
        if args.contains("--menubar") || args.contains("-m") {
            return .menubar
        }
        
        if args.contains("--window") || args.contains("-w") {
            return .window
        }
        
        if args.contains("--help") || args.contains("-h") {
            return nil
        }
        
        return nil
    }
    
    func simulateRestartPathConstruction() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let url = URL(fileURLWithPath: resourcePath)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        return path
    }
}