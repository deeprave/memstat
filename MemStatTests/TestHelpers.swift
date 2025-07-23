import Foundation
import XCTest
@testable import MemStat

extension XCTestCase {
    
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
    
    func XCTAssertWithinTolerance(_ value: Double, expected: Double, tolerance: Double, file: StaticString = #file, line: UInt = #line) {
        let difference = abs(value - expected)
        let toleranceAmount = expected * tolerance
        XCTAssertLessThanOrEqual(difference, toleranceAmount, 
                                "Value \(value) is not within \(tolerance * 100)% of expected \(expected)", 
                                file: file, line: line)
    }
}

struct TestDataGenerator {
    
    static func mockMemoryStats(pressure: String = "Normal") -> MemoryStats {
        return MemoryStats.mock(pressure: pressure)
    }
    
    static func mockProcessInfo(count: Int = 5) -> [MemStat.ProcessInfo] {
        return (0..<count).map { index in
            let memoryPercent = Double(20 - index * 2)
            let memoryBytes = UInt64(memoryPercent) * 100_000_000
            let virtualMemoryBytes = UInt64(memoryPercent) * 200_000_000
            let cpuPercent = Double(index * 5)
            
            return MemStat.ProcessInfo(
                pid: Int32(1000 + index),
                memoryPercent: memoryPercent,
                memoryBytes: memoryBytes,
                virtualMemoryBytes: virtualMemoryBytes,
                cpuPercent: cpuPercent,
                command: "TestProcess\(index)"
            )
        }
    }
}