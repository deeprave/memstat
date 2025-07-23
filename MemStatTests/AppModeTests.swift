import XCTest
@testable import MemStat

class AppModeTests: XCTestCase {
    
    // MARK: - Enum Cases Tests
    
    func testAppModeEnumCases() {
        let allCases = AppMode.allCases
        XCTAssertEqual(allCases.count, 2, "Should have exactly 2 app modes")
        XCTAssertTrue(allCases.contains(.menubar), "Should contain menubar mode")
        XCTAssertTrue(allCases.contains(.window), "Should contain window mode")
    }
    
    // MARK: - Raw Value Tests
    
    func testAppModeRawValues() {
        XCTAssertEqual(AppMode.menubar.rawValue, "menubar", "Menubar mode raw value should be 'menubar'")
        XCTAssertEqual(AppMode.window.rawValue, "window", "Window mode raw value should be 'window'")
    }
    
    func testAppModeInitFromRawValue() {
        XCTAssertEqual(AppMode(rawValue: "menubar"), .menubar, "Should initialize menubar mode from raw value")
        XCTAssertEqual(AppMode(rawValue: "window"), .window, "Should initialize window mode from raw value")
        XCTAssertNil(AppMode(rawValue: "invalid"), "Should return nil for invalid raw value")
        XCTAssertNil(AppMode(rawValue: ""), "Should return nil for empty raw value")
    }
    
    // MARK: - Display Name Tests
    
    func testAppModeDisplayNames() {
        XCTAssertEqual(AppMode.menubar.displayName, "Menu Bar", "Menubar display name should be 'Menu Bar'")
        XCTAssertEqual(AppMode.window.displayName, "Regular Window", "Window display name should be 'Regular Window'")
    }
    
    func testDisplayNamesAreUserFriendly() {
        for mode in AppMode.allCases {
            let displayName = mode.displayName
            XCTAssertFalse(displayName.isEmpty, "Display name should not be empty for \(mode)")
            XCTAssertFalse(displayName.contains("_"), "Display name should not contain underscores for \(mode)")
            XCTAssertTrue(displayName.first?.isUppercase == true, "Display name should start with uppercase for \(mode)")
        }
    }
    
    // MARK: - Equality Tests
    
    func testAppModeEquality() {
        XCTAssertEqual(AppMode.menubar, AppMode.menubar, "Same modes should be equal")
        XCTAssertEqual(AppMode.window, AppMode.window, "Same modes should be equal")
        XCTAssertNotEqual(AppMode.menubar, AppMode.window, "Different modes should not be equal")
    }
    
    // MARK: - String Conversion Tests
    
    func testStringConversion() {
        XCTAssertEqual("\(AppMode.menubar)", "menubar", "String interpolation should use raw value")
        XCTAssertEqual("\(AppMode.window)", "window", "String interpolation should use raw value")
    }
    
    // MARK: - CaseIterable Tests
    
    func testCaseIterableConformance() {
        let allCases = AppMode.allCases
        XCTAssertTrue(allCases is [AppMode], "allCases should be array of AppMode")
        
        let uniqueCases = Set(allCases.map { $0.rawValue })
        XCTAssertEqual(uniqueCases.count, allCases.count, "All cases should have unique raw values")
    }
    
    func testAllCasesContainsAllModes() {
        let allCases = AppMode.allCases
        
        XCTAssertTrue(allCases.contains(.menubar), "allCases should contain menubar")
        XCTAssertTrue(allCases.contains(.window), "allCases should contain window")
        
        XCTAssertEqual(allCases.count, 2, "Should have exactly 2 cases")
    }
    
    // MARK: - UserDefaults Integration Tests
    
    func testUserDefaultsIntegration() {
        let testKey = "TestAppMode"
        
        UserDefaults.standard.set(AppMode.menubar.rawValue, forKey: testKey)
        let loadedMenubarMode = AppMode(rawValue: UserDefaults.standard.string(forKey: testKey) ?? "")
        XCTAssertEqual(loadedMenubarMode, .menubar, "Should correctly save and load menubar mode")
        
        UserDefaults.standard.set(AppMode.window.rawValue, forKey: testKey)
        let loadedWindowMode = AppMode(rawValue: UserDefaults.standard.string(forKey: testKey) ?? "")
        XCTAssertEqual(loadedWindowMode, .window, "Should correctly save and load window mode")
        
        UserDefaults.standard.removeObject(forKey: testKey)
    }
    
    func testUserDefaultsFallback() {
        let testKey = "NonExistentTestKey"
        
        let fallbackMode = AppMode(rawValue: UserDefaults.standard.string(forKey: testKey) ?? AppMode.window.rawValue) ?? .window
        XCTAssertEqual(fallbackMode, .window, "Should fall back to window mode when key doesn't exist")
    }
}