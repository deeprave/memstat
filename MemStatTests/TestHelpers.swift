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
        let basic = BasicMemoryInfo(
            totalMemory: 17_179_869_184,
            usedMemory: 10_737_418_240,
            freeMemory: 6_442_450_944,
            memoryPressure: pressure
        )
        
        let detailed = DetailedMemoryInfo(
            activeMemory: 4_294_967_296,
            inactiveMemory: 2_147_483_648,
            wiredMemory: 3_221_225_472,
            compressedMemory: 1_073_741_824
        )
        
        let app = AppMemoryInfo(
            appPhysicalMemory: 2_147_483_648,
            appVirtualMemory: 8_589_934_592,
            anonymousMemory: 3_221_225_472,
            fileBackedMemory: 1_073_741_824
        )
        
        let swap = SwapInfo(
            swapTotalMemory: 2_147_483_648,
            swapUsedMemory: 536_870_912,
            swapFreeMemory: 1_610_612_736,
            swapUtilization: 25.0,
            swapIns: 1234567,
            swapOuts: 987654
        )
        
        return MemoryStats(
            basic: basic,
            detailed: detailed,
            app: app,
            swap: swap,
            topProcesses: []
        )
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