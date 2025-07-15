import Foundation
import XCTest
@testable import MemStat

// Test helper extensions and utilities

extension XCTestCase {
    
    /// Wait for a condition to become true within a timeout period
    func waitForCondition(timeout: TimeInterval = 5.0, condition: () -> Bool) -> Bool {
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                return true
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        return false
    }
    
    /// Assert that a value is within a percentage tolerance of an expected value
    func XCTAssertWithinTolerance(_ value: Double, expected: Double, tolerance: Double, file: StaticString = #file, line: UInt = #line) {
        let difference = abs(value - expected)
        let toleranceAmount = expected * tolerance
        XCTAssertLessThanOrEqual(difference, toleranceAmount, 
                                "Value \(value) is not within \(tolerance * 100)% of expected \(expected)", 
                                file: file, line: line)
    }
}

// Mock data generators for testing

struct TestDataGenerator {
    
    static func mockMemoryStats(pressure: MemoryPressure = .normal) -> MemoryStats {
        return MemoryStats(
            totalMemory: 17_179_869_184, // 16 GB
            usedMemory: 10_737_418_240,  // 10 GB
            freeMemory: 6_442_450_944,   // 6 GB
            activeMemory: 4_294_967_296,  // 4 GB
            inactiveMemory: 2_147_483_648, // 2 GB
            wiredMemory: 3_221_225_472,   // 3 GB
            compressedMemory: 1_073_741_824, // 1 GB
            swapTotalMemory: 2_147_483_648,  // 2 GB
            swapUsedMemory: 536_870_912,     // 512 MB
            swapFreeMemory: 1_610_612_736,   // 1.5 GB
            swapIns: 1234567,
            swapOuts: 987654,
            pressure: pressure
        )
    }
    
    static func mockProcessInfo(count: Int = 5) -> [ProcessInfo] {
        return (0..<count).map { index in
            ProcessInfo(
                pid: Int32(1000 + index),
                command: "TestProcess\(index)",
                memoryPercent: Double(20 - index * 2),
                memoryBytes: UInt64((20 - index * 2)) * 100_000_000,
                virtualMemoryBytes: UInt64((20 - index * 2)) * 200_000_000,
                cpuPercent: Double(index * 5)
            )
        }
    }
}