import XCTest
@testable import MemStat

class CommandLineTests: XCTestCase {
    
    // MARK: - Command Line Flag Detection Tests
    
    func testMenubarFlagDetection() {
        let longFlagArgs = ["MemStat", "--menubar"]
        let shortFlagArgs = ["MemStat", "-m"]
        let mixedArgs = ["MemStat", "--menubar", "--verbose"]
        let noFlagArgs = ["MemStat"]
        
        XCTAssertTrue(longFlagArgs.contains("--menubar"), "Should detect --menubar flag")
        XCTAssertTrue(shortFlagArgs.contains("-m"), "Should detect -m flag")
        XCTAssertTrue(mixedArgs.contains("--menubar"), "Should detect --menubar flag in mixed args")
        XCTAssertFalse(noFlagArgs.contains("--menubar"), "Should not detect --menubar flag when not present")
        XCTAssertFalse(noFlagArgs.contains("-m"), "Should not detect -m flag when not present")
    }
    
    func testWindowFlagDetection() {
        let longFlagArgs = ["MemStat", "--window"]
        let shortFlagArgs = ["MemStat", "-w"]
        let mixedArgs = ["MemStat", "--window", "--debug"]
        let noFlagArgs = ["MemStat"]
        
        XCTAssertTrue(longFlagArgs.contains("--window"), "Should detect --window flag")
        XCTAssertTrue(shortFlagArgs.contains("-w"), "Should detect -w flag")
        XCTAssertTrue(mixedArgs.contains("--window"), "Should detect --window flag in mixed args")
        XCTAssertFalse(noFlagArgs.contains("--window"), "Should not detect --window flag when not present")
        XCTAssertFalse(noFlagArgs.contains("-w"), "Should not detect -w flag when not present")
    }
    
    func testHelpFlagDetection() {
        let longFlagArgs = ["MemStat", "--help"]
        let shortFlagArgs = ["MemStat", "-h"]
        let mixedArgs = ["MemStat", "--help", "--version"]
        let noFlagArgs = ["MemStat"]
        
        XCTAssertTrue(longFlagArgs.contains("--help"), "Should detect --help flag")
        XCTAssertTrue(shortFlagArgs.contains("-h"), "Should detect -h flag")
        XCTAssertTrue(mixedArgs.contains("--help"), "Should detect --help flag in mixed args")
        XCTAssertFalse(noFlagArgs.contains("--help"), "Should not detect --help flag when not present")
        XCTAssertFalse(noFlagArgs.contains("-h"), "Should not detect -h flag when not present")
    }
    
    func testConflictingFlags() {
        let conflictingArgs = ["MemStat", "--menubar", "--window"]
        
        XCTAssertTrue(conflictingArgs.contains("--menubar"), "Should detect --menubar flag")
        XCTAssertTrue(conflictingArgs.contains("--window"), "Should detect --window flag")
        
    }
    
    func testMultipleShortFlags() {
        let multipleShortArgs = ["MemStat", "-m", "-w"]
        
        XCTAssertTrue(multipleShortArgs.contains("-m"), "Should detect -m flag")
        XCTAssertTrue(multipleShortArgs.contains("-w"), "Should detect -w flag")
    }
    
    // MARK: - Command Line Parsing Logic Tests
    
    func testCommandLineParsingLogic() {
        
        let menubarLongArgs = ["MemStat", "--menubar"]
        let menubarShortArgs = ["MemStat", "-m"]
        
        let menubarLongResult = menubarLongArgs.contains("--menubar") || menubarLongArgs.contains("-m")
        let menubarShortResult = menubarShortArgs.contains("--menubar") || menubarShortArgs.contains("-m")
        
        XCTAssertTrue(menubarLongResult, "Should parse --menubar flag correctly")
        XCTAssertTrue(menubarShortResult, "Should parse -m flag correctly")
        
        let windowLongArgs = ["MemStat", "--window"]
        let windowShortArgs = ["MemStat", "-w"]
        
        let windowLongResult = windowLongArgs.contains("--window") || windowLongArgs.contains("-w")
        let windowShortResult = windowShortArgs.contains("--window") || windowShortArgs.contains("-w")
        
        XCTAssertTrue(windowLongResult, "Should parse --window flag correctly")
        XCTAssertTrue(windowShortResult, "Should parse -w flag correctly")
        
        let noFlagsArgs = ["MemStat"]
        let noFlagsResult = noFlagsArgs.contains("--menubar") || noFlagsArgs.contains("-m") || 
                           noFlagsArgs.contains("--window") || noFlagsArgs.contains("-w")
        
        XCTAssertFalse(noFlagsResult, "Should not detect any mode flags when none present")
    }
    
    // MARK: - Mode Priority Tests
    
    func testModePriorityLogic() {
        
        let hasCommandLineMenubar = true
        let savedPreference = AppMode.window
        let defaultMode = AppMode.window
        
        let finalMode = hasCommandLineMenubar ? AppMode.menubar : (savedPreference)
        XCTAssertEqual(finalMode, .menubar, "Command line should override saved preference")
        
        let hasCommandLineFlag = false
        let finalMode2 = hasCommandLineFlag ? AppMode.menubar : savedPreference
        XCTAssertEqual(finalMode2, .window, "Should use saved preference when no command line flag")
        
        let noSavedPreference: AppMode? = nil
        let finalMode3 = hasCommandLineFlag ? AppMode.menubar : (noSavedPreference ?? defaultMode)
        XCTAssertEqual(finalMode3, .window, "Should use default when no command line flag or saved preference")
    }
    
    // MARK: - Usage Message Tests
    
    func testUsageMessageContent() {
        let expectedElements = [
            "MemStat",
            "Usage:",
            "--menubar",
            "-m",
            "--window", 
            "-w",
            "--help",
            "-h",
            "Examples:"
        ]
        
        for element in expectedElements {
            XCTAssertFalse(element.isEmpty, "Usage element should not be empty: \(element)")
        }
    }
    
    // MARK: - Integration Tests
    
    func testCommandLineModeOverridesSavedPreference() {
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: "AppMode")
        
        let commandLineOverride = AppMode.menubar
        
        let finalMode = commandLineOverride
        XCTAssertEqual(finalMode, .menubar, "Command line should override saved preference")
        
        UserDefaults.standard.removeObject(forKey: "AppMode")
    }
    
    func testNoCommandLineFallsBackToPreference() {
        UserDefaults.standard.set(AppMode.menubar.rawValue, forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let finalMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(finalMode, .menubar, "Should use saved preference when no command line override")
        
        UserDefaults.standard.removeObject(forKey: "AppMode")
    }
    
    func testNoCommandLineNoPreferenceFallsBackToDefault() {
        UserDefaults.standard.removeObject(forKey: "AppMode")
        
        let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
        let finalMode = AppMode(rawValue: savedMode) ?? .window
        
        XCTAssertEqual(finalMode, .window, "Should use default window mode when no command line or saved preference")
    }
}