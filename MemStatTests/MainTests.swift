import XCTest
import Cocoa
@testable import MemStat

class MainTests: XCTestCase {
    
    // MARK: - Test Environment Detection
    
    func testIsRunningTests() {
        let testClass = NSClassFromString("XCTestCase")
        XCTAssertNotNil(testClass, "XCTestCase should be available in test environment")
        
        let isInTestEnvironment = NSClassFromString("XCTestCase") != nil
        XCTAssertTrue(isInTestEnvironment, "Should correctly detect test environment")
    }
    
    func testXCTestCaseDetection() {
        let xcTestCase = NSClassFromString("XCTestCase")
        XCTAssertNotNil(xcTestCase)
        XCTAssertTrue(xcTestCase != nil)
    }
    
    // MARK: - Bundle Identifier Tests
    
    func testAppConstantsBundleIdentifier() {
        let currentBundleId = AppConstants.currentBundleIdentifier()
        XCTAssertFalse(currentBundleId.isEmpty)
        
        if let bundleId = Bundle.main.bundleIdentifier {
            XCTAssertEqual(currentBundleId, bundleId)
        } else {
            XCTAssertEqual(currentBundleId, "io.uniquode.MemStat")
        }
    }
    
    func testBundleIdentifierFallback() {
        let bundleId = AppConstants.currentBundleIdentifier()
        
        XCTAssertFalse(bundleId.isEmpty)
        
        if Bundle.main.bundleIdentifier == nil {
            XCTAssertEqual(bundleId, "io.uniquode.MemStat")
        }
    }
    
    func testBundleIdentifierConsistency() {
        let bundleId1 = AppConstants.currentBundleIdentifier()
        let bundleId2 = AppConstants.currentBundleIdentifier()
        
        XCTAssertEqual(bundleId1, bundleId2, "Bundle identifier should be consistent")
    }
    
    // MARK: - NSWorkspace Integration Tests
    
    func testNSWorkspaceAccess() {
        let workspace = NSWorkspace.shared
        XCTAssertNotNil(workspace)
        
        let runningApps = workspace.runningApplications
        XCTAssertNotNil(runningApps)
        XCTAssertGreaterThan(runningApps.count, 0, "Should have at least one running app (ourselves)")
    }
    
    func testRunningApplicationsContainsSelf() {
        let runningApps = NSWorkspace.shared.runningApplications
        let currentApp = NSRunningApplication.current
        
        XCTAssertTrue(runningApps.contains(currentApp), "Running apps should contain current application")
    }
    
    func testCurrentApplicationProperties() {
        let currentApp = NSRunningApplication.current
        
        XCTAssertNotNil(currentApp)
        XCTAssertNotNil(currentApp.bundleIdentifier)
        XCTAssertFalse(currentApp.bundleIdentifier?.isEmpty ?? true)
    }
    
    // MARK: - Instance Detection Logic Tests
    
    func testInstanceDetectionLogic() {
        let runningApps = NSWorkspace.shared.runningApplications
        let currentApp = NSRunningApplication.current
        let currentBundleId = currentApp.bundleIdentifier ?? AppConstants.currentBundleIdentifier()
        
        let otherInstances = runningApps.filter { app in
            return app.bundleIdentifier == currentBundleId && app != currentApp
        }
        
        XCTAssertEqual(otherInstances.count, 0, "Should not find other instances during test run")
    }
    
    func testInstanceFilteringLogic() {
        let runningApps = NSWorkspace.shared.runningApplications
        let currentApp = NSRunningApplication.current
        let currentBundleId = currentApp.bundleIdentifier ?? AppConstants.currentBundleIdentifier()
        
        let sameBundle = runningApps.filter { app in
            return app.bundleIdentifier == currentBundleId
        }
        
        XCTAssertGreaterThanOrEqual(sameBundle.count, 1, "Should find at least our own instance")
        
        XCTAssertTrue(sameBundle.contains(currentApp), "Should contain current app")
        
        let others = sameBundle.filter { app in
            return app != currentApp
        }
        
        XCTAssertEqual(others.count, 0, "Should not find other instances during test")
    }
    
    // MARK: - Application Activation Tests
    
    func testApplicationActivationMethod() {
        let currentApp = NSRunningApplication.current
        
        let canActivate = currentApp.responds(to: #selector(NSRunningApplication.activate(options:)))
        XCTAssertTrue(canActivate, "NSRunningApplication should respond to activate(options:)")
    }
    
    func testActivationOptions() {
        let options: NSApplication.ActivationOptions = []
        XCTAssertNotNil(options)
        
        let ignoreOtherApps: NSApplication.ActivationOptions = [.activateIgnoringOtherApps]
        XCTAssertNotNil(ignoreOtherApps)
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyBundleIdentifierHandling() {
        let runningApps = NSWorkspace.shared.runningApplications
        
        let appsWithoutBundleId = runningApps.filter { app in
            return app.bundleIdentifier == nil
        }
        
        XCTAssertGreaterThanOrEqual(appsWithoutBundleId.count, 0)
    }
    
    func testBundleIdentifierComparison() {
        let bundleId = AppConstants.currentBundleIdentifier()
        let sameBundleId = AppConstants.currentBundleIdentifier()
        let differentBundleId = "com.apple.finder"
        
        XCTAssertEqual(bundleId, sameBundleId)
        XCTAssertNotEqual(bundleId, differentBundleId)
        
        let upperCaseBundleId = bundleId.uppercased()
        XCTAssertNotEqual(bundleId, upperCaseBundleId, "Bundle ID comparison should be case sensitive")
    }
    
    // MARK: - NSApplication Integration Tests
    
    func testNSApplicationSharedAccess() {
        let app = NSApplication.shared
        XCTAssertNotNil(app)
        
        let delegate = app.delegate
        XCTAssertNotNil(delegate, "App should have a delegate during tests")
        
        if let appDelegate = delegate as? AppDelegate {
            XCTAssertNotNil(appDelegate)
        }
    }
    
    func testAppDelegateCreation() {
        let delegate = AppDelegate()
        XCTAssertNotNil(delegate)
    }
    
    // MARK: - System Integration Tests
    
    func testWorkspaceNotifications() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        XCTAssertNotNil(notificationCenter)
        
        let launchNotification = NSWorkspace.didLaunchApplicationNotification
        XCTAssertNotNil(launchNotification)
        
        let terminateNotification = NSWorkspace.didTerminateApplicationNotification
        XCTAssertNotNil(terminateNotification)
    }
    
    func testMultipleInstanceSimulation() {
        let runningApps = NSWorkspace.shared.runningApplications
        let currentApp = NSRunningApplication.current
        let currentBundleId = currentApp.bundleIdentifier ?? AppConstants.currentBundleIdentifier()
        
        let allInstances = runningApps.filter { app in
            return app.bundleIdentifier == currentBundleId
        }
        
        let simulatedOthers = allInstances.filter { app in
            return app != currentApp
        }
        
        XCTAssertEqual(simulatedOthers.count, 0, "Should correctly filter out current app")
        
        let wouldExit = !simulatedOthers.isEmpty
        XCTAssertFalse(wouldExit, "Should not exit during normal test execution")
    }
    
    // MARK: - Performance Tests
    
    func testInstanceDetectionPerformance() {
        measure {
            let runningApps = NSWorkspace.shared.runningApplications
            let currentApp = NSRunningApplication.current
            let currentBundleId = currentApp.bundleIdentifier ?? AppConstants.currentBundleIdentifier()
            
            let _ = runningApps.filter { app in
                return app.bundleIdentifier == currentBundleId && app != currentApp
            }
        }
    }
    
    func testBundleIdentifierPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = AppConstants.currentBundleIdentifier()
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testWorkspaceAccessibility() {
        XCTAssertNoThrow(NSWorkspace.shared.runningApplications)
        XCTAssertNoThrow(NSRunningApplication.current)
    }
    
    func testBundleAccessibility() {
        XCTAssertNoThrow(Bundle.main.bundleIdentifier)
        XCTAssertNoThrow(Bundle.main)
    }
}

// MARK: - Helper Extensions for Testing

extension MainTests {
    
    /// Helper to simulate the main.swift instance detection logic
    func simulateInstanceDetection(with mockApps: [MockRunningApplication], currentBundleId: String) -> [MockRunningApplication] {
        return mockApps.filter { app in
            return app.bundleIdentifier == currentBundleId && !app.isCurrent
        }
    }
}

// MARK: - Mock Objects for Testing

class MockRunningApplication {
    let bundleIdentifier: String?
    let isCurrent: Bool
    var activationCallCount = 0
    
    init(bundleIdentifier: String?, isCurrent: Bool = false) {
        self.bundleIdentifier = bundleIdentifier
        self.isCurrent = isCurrent
    }
    
    func activate() {
        activationCallCount += 1
    }
}

// MARK: - Integration Helper Tests

extension MainTests {
    
    func testMainLogicIntegration() {
        let isTestEnv = NSClassFromString("XCTestCase") != nil
        XCTAssertTrue(isTestEnv, "Should be in test environment")
        
        let currentApp = NSRunningApplication.current
        let bundleId = currentApp.bundleIdentifier ?? AppConstants.currentBundleIdentifier()
        XCTAssertFalse(bundleId.isEmpty)
        
        let runningApps = NSWorkspace.shared.runningApplications
        XCTAssertGreaterThan(runningApps.count, 0)
        
        XCTAssertNotNil(currentApp)
        
        let otherInstances = runningApps.filter { app in
            return app.bundleIdentifier == bundleId && app != currentApp
        }
        
        XCTAssertEqual(otherInstances.count, 0)
        
        let app = NSApplication.shared
        let delegate = AppDelegate()
        XCTAssertNotNil(app)
        XCTAssertNotNil(delegate)
    }
}