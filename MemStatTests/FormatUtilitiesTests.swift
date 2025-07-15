import XCTest
@testable import MemStat

class FormatUtilitiesTests: XCTestCase {
    
    func testFormatBytes() {
        // Test GB formatting
        XCTAssertEqual(FormatUtilities.formatBytes(1_073_741_824), "1 GB")
        XCTAssertEqual(FormatUtilities.formatBytes(2_147_483_648), "2 GB")
        XCTAssertEqual(FormatUtilities.formatBytes(1_610_612_736), "1.5 GB")
        
        // Test MB formatting
        XCTAssertEqual(FormatUtilities.formatBytes(1_048_576), "1 MB")
        XCTAssertEqual(FormatUtilities.formatBytes(524_288), "512 KB")
        XCTAssertEqual(FormatUtilities.formatBytes(104_857_600), "100 MB")
        
        // Test edge cases
        XCTAssertEqual(FormatUtilities.formatBytes(0), "0 bytes")
        XCTAssertEqual(FormatUtilities.formatBytes(1023), "1,023 bytes")
        
        // Test large values
        XCTAssertEqual(FormatUtilities.formatBytes(34_359_738_368), "32 GB")
    }
    
    func testSeparateValueAndUnit() {
        // Test normal cases
        let result1 = FormatUtilities.separateValueAndUnit("1.5 GB")
        XCTAssertEqual(result1.value, "1.5")
        XCTAssertEqual(result1.unit, "GB")
        
        let result2 = FormatUtilities.separateValueAndUnit("512 MB")
        XCTAssertEqual(result2.value, "512")
        XCTAssertEqual(result2.unit, "MB")
        
        // Test edge cases
        let result3 = FormatUtilities.separateValueAndUnit("NoSpace")
        XCTAssertEqual(result3.value, "NoSpace")
        XCTAssertEqual(result3.unit, "")
        
        let result4 = FormatUtilities.separateValueAndUnit("")
        XCTAssertEqual(result4.value, "")
        XCTAssertEqual(result4.unit, "")
        
        // Test multiple spaces
        let result5 = FormatUtilities.separateValueAndUnit("100 MB Free")
        XCTAssertEqual(result5.value, "100")
        XCTAssertEqual(result5.unit, "MB")
    }
    
    func testCreateSortableHeaderText() {
        // Test when not the current sort column
        let text1 = FormatUtilities.createSortableHeaderText("Memory", 
                                                            sortColumn: .memoryPercent, 
                                                            currentSortColumn: .pid, 
                                                            sortDescending: true)
        XCTAssertEqual(text1, "Memory")
        
        // Test when it is the current sort column - descending
        let text2 = FormatUtilities.createSortableHeaderText("Memory", 
                                                            sortColumn: .memoryPercent, 
                                                            currentSortColumn: .memoryPercent, 
                                                            sortDescending: true)
        XCTAssertEqual(text2, "Memory ▼")
        
        // Test when it is the current sort column - ascending
        let text3 = FormatUtilities.createSortableHeaderText("CPU", 
                                                            sortColumn: .cpuPercent, 
                                                            currentSortColumn: .cpuPercent, 
                                                            sortDescending: false)
        XCTAssertEqual(text3, "CPU ▲")
        
        // Test with nil sort column
        let text4 = FormatUtilities.createSortableHeaderText("Name", 
                                                            sortColumn: nil, 
                                                            currentSortColumn: .command, 
                                                            sortDescending: true)
        XCTAssertEqual(text4, "Name")
    }
    
    func testFormatCount() {
        // Test small numbers
        XCTAssertEqual(FormatUtilities.formatCount(0), "0")
        XCTAssertEqual(FormatUtilities.formatCount(999), "999")
        
        // Test thousands
        XCTAssertEqual(FormatUtilities.formatCount(1_000), "1.0K")
        XCTAssertEqual(FormatUtilities.formatCount(1_500), "1.5K")
        XCTAssertEqual(FormatUtilities.formatCount(999_999), "1000.0K")
        
        // Test millions
        XCTAssertEqual(FormatUtilities.formatCount(1_000_000), "1.0M")
        XCTAssertEqual(FormatUtilities.formatCount(1_500_000), "1.5M")
        XCTAssertEqual(FormatUtilities.formatCount(999_999_999), "1000.0M")
        
        // Test large numbers
        XCTAssertEqual(FormatUtilities.formatCount(1_234_567_890), "1234.6M")
    }
}