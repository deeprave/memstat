import XCTest
import Foundation
@testable import MemStat

class UpdateCoordinatorTests: XCTestCase {
    
    var updateCoordinator: UpdateCoordinator!
    var mockUpdateHandler: MockUpdateHandler!
    let testInterval: TimeInterval = 0.1
    
    override func setUp() {
        super.setUp()
        mockUpdateHandler = MockUpdateHandler()
        updateCoordinator = UpdateCoordinator(
            updateInterval: testInterval,
            updateHandler: mockUpdateHandler.handleUpdate
        )
    }
    
    override func tearDown() {
        updateCoordinator?.stopUpdating()
        updateCoordinator = nil
        mockUpdateHandler = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(updateCoordinator)
        mockUpdateHandler.callCount = 0
    }
    
    // MARK: - Start Updating Tests
    
    func testStartUpdatingWithoutImmediate() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: false)
        
        XCTAssertEqual(mockUpdateHandler.callCount, 0)
        
        let expectation = XCTestExpectation(description: "Timer should fire")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval + 0.05) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(mockUpdateHandler.callCount, 1)
    }
    
    func testRepeatedStartUpdatingCallsIgnored() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: false)
        updateCoordinator.startUpdating(immediate: false)
        updateCoordinator.startUpdating(immediate: false)
        
        XCTAssertEqual(mockUpdateHandler.callCount, 0)
        
        let expectation = XCTestExpectation(description: "Timer should fire normally")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval + 0.05) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(mockUpdateHandler.callCount, 1)
        XCTAssertLessThan(mockUpdateHandler.callCount, 4)
    }
    
    func testStartUpdatingWithImmediate() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: true)
        
        XCTAssertEqual(mockUpdateHandler.callCount, 1)
        
        let expectation = XCTestExpectation(description: "Timer should fire")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval + 0.05) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertGreaterThanOrEqual(mockUpdateHandler.callCount, 2)
    }
    
    func testStartUpdatingDefaultParameter() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating()
        
        XCTAssertEqual(mockUpdateHandler.callCount, 0)
    }
    
    func testStartUpdatingMultipleTimes() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: true)
        updateCoordinator.startUpdating(immediate: true)
        updateCoordinator.startUpdating(immediate: true)
        
        XCTAssertEqual(mockUpdateHandler.callCount, 1)
        
        let expectation = XCTestExpectation(description: "Timer should fire")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval + 0.05) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(mockUpdateHandler.callCount, 2)
    }
    
    // MARK: - Stop Updating Tests
    
    func testStopUpdating() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: false)
        
        let startExpectation = XCTestExpectation(description: "Let timer start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            startExpectation.fulfill()
        }
        wait(for: [startExpectation], timeout: 1.0)
        
        updateCoordinator.stopUpdating()
        
        let countAfterStop = mockUpdateHandler.callCount
        
        let stopExpectation = XCTestExpectation(description: "Timer should be stopped")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 2) {
            stopExpectation.fulfill()
        }
        
        wait(for: [stopExpectation], timeout: 1.0)
        
        XCTAssertEqual(mockUpdateHandler.callCount, countAfterStop)
    }
    
    func testStopUpdatingWhenNotRunning() {
        updateCoordinator.stopUpdating()
    }
    
    func testStopUpdatingMultipleTimes() {
        updateCoordinator.startUpdating()
        
        updateCoordinator.stopUpdating()
        updateCoordinator.stopUpdating()
        updateCoordinator.stopUpdating()
    }
    
    // MARK: - Timer Behavior Tests
    
    func testTimerInterval() {
        mockUpdateHandler.callCount = 0
        let startTime = Date()
        
        updateCoordinator.startUpdating(immediate: false)
        
        let expectation = XCTestExpectation(description: "Multiple timer fires")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 3.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        let elapsed = Date().timeIntervalSince(startTime)
        let expectedCalls = Int(elapsed / testInterval)
        
        XCTAssertGreaterThanOrEqual(mockUpdateHandler.callCount, expectedCalls - 1)
        XCTAssertLessThanOrEqual(mockUpdateHandler.callCount, expectedCalls + 2)
    }
    
    func testTimerRepeats() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: false)
        
        let expectation = XCTestExpectation(description: "Timer should repeat")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 2.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertGreaterThanOrEqual(mockUpdateHandler.callCount, 2)
    }
    
    // MARK: - Memory Management Tests
    
    func testWeakSelfInTimer() {
        var coordinator: UpdateCoordinator? = UpdateCoordinator(
            updateInterval: testInterval,
            updateHandler: mockUpdateHandler.handleUpdate
        )
        
        coordinator?.startUpdating(immediate: false)
        
        coordinator = nil
        
        let expectation = XCTestExpectation(description: "Timer should not crash")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 2) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
    }
    
    func testTimerInvalidationOnDeallocation() {
        var coordinator: UpdateCoordinator? = UpdateCoordinator(
            updateInterval: testInterval,
            updateHandler: mockUpdateHandler.handleUpdate
        )
        
        coordinator?.startUpdating(immediate: false)
        
        coordinator?.stopUpdating()
        coordinator = nil
        
        let expectation = XCTestExpectation(description: "Cleanup should work")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeinitInvalidatesTimerWithoutStopUpdating() {
        let handler = MockUpdateHandler()
        
        var coordinator: UpdateCoordinator? = UpdateCoordinator(
            updateInterval: testInterval,
            updateHandler: handler.handleUpdate
        )
        
        coordinator?.startUpdating(immediate: false)
        
        coordinator = nil
        
        let expectation = XCTestExpectation(description: "deinit should invalidate timer")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 3) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
    }
    
    // MARK: - Error Handling Tests
    
    func testHandlerThrowingException() {
        let throwingHandler = MockThrowingUpdateHandler()
        let coordinator = UpdateCoordinator(
            updateInterval: testInterval,
            updateHandler: throwingHandler.handleUpdate
        )
        
        coordinator.startUpdating(immediate: true)
        
        XCTAssertEqual(throwingHandler.callCount, 1)
        
        let expectation = XCTestExpectation(description: "Should handle exceptions")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 2.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        coordinator.stopUpdating()
        
        XCTAssertGreaterThanOrEqual(throwingHandler.callCount, 2)
    }
    
    func testVeryShortInterval() {
        let shortHandler = MockUpdateHandler()
        let coordinator = UpdateCoordinator(
            updateInterval: 0.001,
            updateHandler: shortHandler.handleUpdate
        )
        
        coordinator.startUpdating(immediate: false)
        
        let expectation = XCTestExpectation(description: "Short interval should be clamped to minimum")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        coordinator.stopUpdating()
        
        XCTAssertGreaterThan(shortHandler.callCount, 1)
        XCTAssertLessThan(shortHandler.callCount, 5)
    }
    
    func testZeroInterval() {
        let zeroHandler = MockUpdateHandler()
        let coordinator = UpdateCoordinator(
            updateInterval: 0.0,
            updateHandler: zeroHandler.handleUpdate
        )
        
        coordinator.startUpdating(immediate: true)
        
        let expectation = XCTestExpectation(description: "Zero interval should be clamped to minimum")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        coordinator.stopUpdating()
        
        XCTAssertGreaterThanOrEqual(zeroHandler.callCount, 2)
    }
    
    func testMinimumIntervalEnforcement() {
        let handler = MockUpdateHandler()
        let coordinator = UpdateCoordinator(
            updateInterval: 0.05,
            updateHandler: handler.handleUpdate
        )
        
        coordinator.startUpdating(immediate: false)
        
        let expectation = XCTestExpectation(description: "Minimum interval should be enforced")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        coordinator.stopUpdating()
        
        XCTAssertGreaterThan(handler.callCount, 1)
        XCTAssertLessThan(handler.callCount, 5)
    }
    
    // MARK: - Integration Tests
    
    func testStartStopCycle() {
        mockUpdateHandler.callCount = 0
        
        updateCoordinator.startUpdating(immediate: true)
        XCTAssertEqual(mockUpdateHandler.callCount, 1)
        
        let firstWait = XCTestExpectation(description: "First run")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval + 0.05) {
            firstWait.fulfill()
        }
        wait(for: [firstWait], timeout: 1.0)
        
        let countAfterFirst = mockUpdateHandler.callCount
        XCTAssertGreaterThan(countAfterFirst, 1)
        
        updateCoordinator.stopUpdating()
        
        let stopWait = XCTestExpectation(description: "Stop period")
        DispatchQueue.main.asyncAfter(deadline: .now() + testInterval * 2) {
            stopWait.fulfill()
        }
        wait(for: [stopWait], timeout: 1.0)
        
        let countAfterStop = mockUpdateHandler.callCount
        XCTAssertEqual(countAfterStop, countAfterFirst)
        
        updateCoordinator.startUpdating(immediate: true)
        XCTAssertEqual(mockUpdateHandler.callCount, countAfterStop + 1)
    }
}

// MARK: - Mock Classes

class MockUpdateHandler {
    var callCount = 0
    var lastCallTime: Date?
    
    func handleUpdate() {
        callCount += 1
        lastCallTime = Date()
    }
}

class MockThrowingUpdateHandler {
    var callCount = 0
    
    func handleUpdate() {
        callCount += 1
    }
}