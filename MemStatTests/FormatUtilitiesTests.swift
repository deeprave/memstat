import XCTest
import Cocoa
@testable import MemStat

class FormatUtilitiesTests: XCTestCase {
    
    func testFormatBytes() {
        XCTAssertEqual(FormatUtilities.formatBytes(1_073_741_824), "1 GB")
        XCTAssertEqual(FormatUtilities.formatBytes(2_147_483_648), "2 GB")
        XCTAssertEqual(FormatUtilities.formatBytes(1_610_612_736), "1.5 GB")
        
        XCTAssertEqual(FormatUtilities.formatBytes(1_048_576), "1 MB")
        XCTAssertEqual(FormatUtilities.formatBytes(524_288), "512 KB")
        XCTAssertEqual(FormatUtilities.formatBytes(104_857_600), "100 MB")
        
        XCTAssertEqual(FormatUtilities.formatBytes(0), "Zero b")
        XCTAssertEqual(FormatUtilities.formatBytes(1023), "1,023 b")
        
        XCTAssertEqual(FormatUtilities.formatBytes(34_359_738_368), "32 GB")
    }
    
    func testSeparateValueAndUnit() {
        let result1 = FormatUtilities.separateValueAndUnit("1.5 GB")
        XCTAssertEqual(result1.value, "1.5")
        XCTAssertEqual(result1.unit, "GB")
        
        let result2 = FormatUtilities.separateValueAndUnit("512 MB")
        XCTAssertEqual(result2.value, "512")
        XCTAssertEqual(result2.unit, "MB")
        
        let result3 = FormatUtilities.separateValueAndUnit("NoSpace")
        XCTAssertEqual(result3.value, "NoSpace")
        XCTAssertEqual(result3.unit, "")
        
        let result4 = FormatUtilities.separateValueAndUnit("")
        XCTAssertEqual(result4.value, "")
        XCTAssertEqual(result4.unit, "")
        
        let result5 = FormatUtilities.separateValueAndUnit("100 MB Free")
        XCTAssertEqual(result5.value, "100")
        XCTAssertEqual(result5.unit, "MB")
    }
    
    func testCreateSortableHeaderText() {
        let text1 = FormatUtilities.createSortableHeaderText("Memory", 
                                                            sortColumn: .memoryPercent, 
                                                            currentSortColumn: .pid, 
                                                            sortDescending: true)
        XCTAssertEqual(text1, "Memory")
        
        let text2 = FormatUtilities.createSortableHeaderText("Memory", 
                                                            sortColumn: .memoryPercent, 
                                                            currentSortColumn: .memoryPercent, 
                                                            sortDescending: true)
        XCTAssertEqual(text2, "Memory ▼")
        
        let text3 = FormatUtilities.createSortableHeaderText("CPU", 
                                                            sortColumn: .cpuPercent, 
                                                            currentSortColumn: .cpuPercent, 
                                                            sortDescending: false)
        XCTAssertEqual(text3, "CPU ▲")
        
        let text4 = FormatUtilities.createSortableHeaderText("Name", 
                                                            sortColumn: nil, 
                                                            currentSortColumn: .command, 
                                                            sortDescending: true)
        XCTAssertEqual(text4, "Name")
    }
    
    func testFormatCount() {
        XCTAssertEqual(FormatUtilities.formatCount(0), "0")
        XCTAssertEqual(FormatUtilities.formatCount(999), "999")
        
        XCTAssertEqual(FormatUtilities.formatCount(1_000), "1.0K")
        XCTAssertEqual(FormatUtilities.formatCount(1_500), "1.5K")
        XCTAssertEqual(FormatUtilities.formatCount(999_999), "1000.0K")
        
        XCTAssertEqual(FormatUtilities.formatCount(1_000_000), "1.0M")
        XCTAssertEqual(FormatUtilities.formatCount(1_500_000), "1.5M")
        XCTAssertEqual(FormatUtilities.formatCount(999_999_999), "1000.0M")
        
        XCTAssertEqual(FormatUtilities.formatCount(1_234_567_890), "1234.6M")
    }
    
    func testCreatePinIcon() {
        let lightAppearance = NSAppearance(named: .aqua)!
        let darkAppearance = NSAppearance(named: .darkAqua)!
        
        let lightIcon = FormatUtilities.createPinIcon(appearance: lightAppearance)
        let darkIcon = FormatUtilities.createPinIcon(appearance: darkAppearance)
        
        XCTAssertEqual(lightIcon.size, NSSize(width: 22, height: 22))
        XCTAssertEqual(darkIcon.size, NSSize(width: 22, height: 22))
    }
    
    func testCreateCloseIcon() {
        let lightAppearance = NSAppearance(named: .aqua)!
        let darkAppearance = NSAppearance(named: .darkAqua)!
        
        let lightIcon = FormatUtilities.createCloseIcon(appearance: lightAppearance)
        let darkIcon = FormatUtilities.createCloseIcon(appearance: darkAppearance)
        
        XCTAssertEqual(lightIcon.size, NSSize(width: 22, height: 22))
        XCTAssertEqual(darkIcon.size, NSSize(width: 22, height: 22))
    }
}