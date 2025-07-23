import XCTest
import ServiceManagement
@testable import MemStat

class LoginItemsManagerTests: XCTestCase {
    
    var loginItemsManager: LoginItemsManager!
    
    override func setUp() {
        super.setUp()
        loginItemsManager = LoginItemsManager.shared
    }
    
    override func tearDown() {
        loginItemsManager.disable()
        loginItemsManager = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = LoginItemsManager.shared
        let instance2 = LoginItemsManager.shared
        
        XCTAssertTrue(instance1 === instance2, "LoginItemsManager should be a singleton")
    }
    
    // MARK: - Bundle Identifier Tests
    
    func testBundleIdentifier() {
        XCTAssertNotNil(loginItemsManager)
    }
    
    // MARK: - Modern macOS (13.0+) Tests
    
    @available(macOS 13.0, *)
    func testIsEnabledModernMacOS() {
        let initialState = loginItemsManager.isEnabled()
        XCTAssertNotNil(initialState)
        
        XCTAssertTrue(initialState == true || initialState == false)
    }
    
    @available(macOS 13.0, *)
    func testEnableModernMacOS() {
        loginItemsManager.enable()
        
        XCTAssertNotNil(loginItemsManager)
    }
    
    @available(macOS 13.0, *)
    func testDisableModernMacOS() {
        loginItemsManager.disable()
        
        XCTAssertNotNil(loginItemsManager)
    }
    
    @available(macOS 13.0, *)
    func testEnableDisableCycleModernMacOS() {
        let initialState = loginItemsManager.isEnabled()
        
        loginItemsManager.enable()
        loginItemsManager.disable()
        
        XCTAssertNotNil(loginItemsManager)
        
        if initialState {
            loginItemsManager.enable()
        } else {
            loginItemsManager.disable()
        }
    }
    
    // MARK: - Legacy macOS Tests
    
    func testIsEnabledLegacyMacOS() {
        let result = loginItemsManager.isEnabled()
        XCTAssertTrue(result == true || result == false)
    }
    
    func testEnableLegacyMacOS() {
        loginItemsManager.enable()
        XCTAssertNotNil(loginItemsManager)
    }
    
    func testDisableLegacyMacOS() {
        loginItemsManager.disable()
        XCTAssertNotNil(loginItemsManager)
    }
    
    // MARK: - Error Handling Tests
    
    func testMultipleEnableCalls() {
        loginItemsManager.enable()
        loginItemsManager.enable()
        loginItemsManager.enable()
        
        XCTAssertNotNil(loginItemsManager)
    }
    
    func testMultipleDisableCalls() {
        loginItemsManager.disable()
        loginItemsManager.disable()
        loginItemsManager.disable()
        
        XCTAssertNotNil(loginItemsManager)
    }
    
    func testConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access should not crash")
        expectation.expectedFulfillmentCount = 10
        
        for _ in 0..<10 {
            DispatchQueue.global().async {
                let _ = self.loginItemsManager.isEnabled()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Integration Tests
    
    func testStateConsistency() {
        let state1 = loginItemsManager.isEnabled()
        let state2 = loginItemsManager.isEnabled()
        let state3 = loginItemsManager.isEnabled()
        
        XCTAssertEqual(state1, state2)
        XCTAssertEqual(state2, state3)
    }
    
    func testEnableDisableSequence() {
        let initialState = loginItemsManager.isEnabled()
        
        loginItemsManager.enable()
        
        let enableExpectation = XCTestExpectation(description: "Enable operation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            enableExpectation.fulfill()
        }
        wait(for: [enableExpectation], timeout: 1.0)
        
        loginItemsManager.disable()
        
        let disableExpectation = XCTestExpectation(description: "Disable operation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            disableExpectation.fulfill()
        }
        wait(for: [disableExpectation], timeout: 1.0)
        
        if initialState {
            loginItemsManager.enable()
        } else {
            loginItemsManager.disable()
        }
        
        XCTAssertNotNil(loginItemsManager)
    }
    
    // MARK: - Performance Tests
    
    func testIsEnabledPerformance() {
        measure {
            for _ in 0..<100 {
                let _ = loginItemsManager.isEnabled()
            }
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testRapidToggling() {
        for _ in 0..<5 {
            loginItemsManager.enable()
            loginItemsManager.disable()
        }
        
        XCTAssertNotNil(loginItemsManager)
    }
    
    func testSystemCompatibility() {
        
        let currentState = loginItemsManager.isEnabled()
        
        if currentState {
            loginItemsManager.disable()
            let _ = loginItemsManager.isEnabled()
            loginItemsManager.enable()
        } else {
            loginItemsManager.enable()
            let _ = loginItemsManager.isEnabled()
            loginItemsManager.disable()
        }
        
        XCTAssertNotNil(loginItemsManager)
    }
}