import Foundation
import Cocoa

public enum ProcessSortColumn {
    case pid, memoryPercent, memoryBytes, virtualMemory, virtualMemoryBytes, cpuPercent, command
}

public struct ProcessInfo {
    public let pid: Int32
    public let memoryPercent: Double
    public let memoryBytes: UInt64
    public let virtualMemoryBytes: UInt64
    public let cpuPercent: Double
    public let command: String
    
    public init(pid: Int32, memoryPercent: Double, memoryBytes: UInt64, virtualMemoryBytes: UInt64, cpuPercent: Double, command: String) {
        self.pid = pid
        self.memoryPercent = memoryPercent
        self.memoryBytes = memoryBytes
        self.virtualMemoryBytes = virtualMemoryBytes
        self.cpuPercent = cpuPercent
        self.command = command
    }
}

public struct MemoryStats {
    public let basic: BasicMemoryInfo
    public let detailed: DetailedMemoryInfo
    public let app: AppMemoryInfo
    public let swap: SwapInfo
    public let topProcesses: [ProcessInfo]
    
    public init(basic: BasicMemoryInfo, detailed: DetailedMemoryInfo, app: AppMemoryInfo, swap: SwapInfo, topProcesses: [ProcessInfo]) {
        self.basic = basic
        self.detailed = detailed
        self.app = app
        self.swap = swap
        self.topProcesses = topProcesses
    }
    
    public struct BasicMemoryInfo {
        public let totalMemory: UInt64
        public let usedMemory: UInt64
        public let freeMemory: UInt64
        public let memoryPressure: String
        
        public init(totalMemory: UInt64, usedMemory: UInt64, freeMemory: UInt64, memoryPressure: String) {
            self.totalMemory = totalMemory
            self.usedMemory = usedMemory
            self.freeMemory = freeMemory
            self.memoryPressure = memoryPressure
        }
        
        public static func mock(pressure: String = "Normal") -> BasicMemoryInfo {
            return BasicMemoryInfo(
                totalMemory: 17_179_869_184,
                usedMemory: 10_737_418_240,
                freeMemory: 6_442_450_944,
                memoryPressure: pressure
            )
        }
    }
    
    public struct DetailedMemoryInfo {
        public let activeMemory: UInt64
        public let inactiveMemory: UInt64
        public let wiredMemory: UInt64
        public let compressedMemory: UInt64
        
        public init(activeMemory: UInt64, inactiveMemory: UInt64, wiredMemory: UInt64, compressedMemory: UInt64) {
            self.activeMemory = activeMemory
            self.inactiveMemory = inactiveMemory
            self.wiredMemory = wiredMemory
            self.compressedMemory = compressedMemory
        }
        
        public static func mock() -> DetailedMemoryInfo {
            return DetailedMemoryInfo(
                activeMemory: 4_294_967_296,
                inactiveMemory: 2_147_483_648,
                wiredMemory: 3_221_225_472,
                compressedMemory: 1_073_741_824
            )
        }
    }
    
    public struct AppMemoryInfo {
        public let appPhysicalMemory: UInt64
        public let appVirtualMemory: UInt64
        public let anonymousMemory: UInt64
        public let fileBackedMemory: UInt64
        
        public init(appPhysicalMemory: UInt64, appVirtualMemory: UInt64, anonymousMemory: UInt64, fileBackedMemory: UInt64) {
            self.appPhysicalMemory = appPhysicalMemory
            self.appVirtualMemory = appVirtualMemory
            self.anonymousMemory = anonymousMemory
            self.fileBackedMemory = fileBackedMemory
        }
        
        public static func mock() -> AppMemoryInfo {
            return AppMemoryInfo(
                appPhysicalMemory: 2_147_483_648,
                appVirtualMemory: 8_589_934_592,
                anonymousMemory: 3_221_225_472,
                fileBackedMemory: 1_073_741_824
            )
        }
    }
    
    public struct SwapInfo {
        public let swapTotalMemory: UInt64
        public let swapUsedMemory: UInt64
        public let swapFreeMemory: UInt64
        public let swapUtilization: Double
        public let swapIns: UInt64
        public let swapOuts: UInt64
        
        public init(swapTotalMemory: UInt64, swapUsedMemory: UInt64, swapFreeMemory: UInt64, swapUtilization: Double, swapIns: UInt64, swapOuts: UInt64) {
            self.swapTotalMemory = swapTotalMemory
            self.swapUsedMemory = swapUsedMemory
            self.swapFreeMemory = swapFreeMemory
            self.swapUtilization = swapUtilization
            self.swapIns = swapIns
            self.swapOuts = swapOuts
        }
        
        public static func mock() -> SwapInfo {
            return SwapInfo(
                swapTotalMemory: 2_147_483_648,
                swapUsedMemory: 536_870_912,
                swapFreeMemory: 1_610_612_736,
                swapUtilization: 25.0,
                swapIns: 1234567,
                swapOuts: 987654
            )
        }
    }
    
    public static func mock(pressure: String = "Normal") -> MemoryStats {
        return MemoryStats(
            basic: BasicMemoryInfo.mock(pressure: pressure),
            detailed: DetailedMemoryInfo.mock(),
            app: AppMemoryInfo.mock(),
            swap: SwapInfo.mock(),
            topProcesses: []
        )
    }
    
    public var totalMemory: UInt64 { basic.totalMemory }
    public var usedMemory: UInt64 { basic.usedMemory }
    public var freeMemory: UInt64 { basic.freeMemory }
    public var memoryPressure: String { basic.memoryPressure }
    public var activeMemory: UInt64 { detailed.activeMemory }
    public var inactiveMemory: UInt64 { detailed.inactiveMemory }
    public var wiredMemory: UInt64 { detailed.wiredMemory }
    public var compressedMemory: UInt64 { detailed.compressedMemory }
    public var appPhysicalMemory: UInt64 { app.appPhysicalMemory }
    public var appVirtualMemory: UInt64 { app.appVirtualMemory }
    public var anonymousMemory: UInt64 { app.anonymousMemory }
    public var fileBackedMemory: UInt64 { app.fileBackedMemory }
    public var swapTotalMemory: UInt64 { swap.swapTotalMemory }
    public var swapUsedMemory: UInt64 { swap.swapUsedMemory }
    public var swapFreeMemory: UInt64 { swap.swapFreeMemory }
    public var swapUtilization: Double { swap.swapUtilization }
    public var swapIns: UInt64 { swap.swapIns }
    public var swapOuts: UInt64 { swap.swapOuts }
}




public protocol TableSectionDelegate: LabelFactory, BackgroundStylist, SortHandler {
    func getCurrentSortColumn() -> ProcessSortColumn
    func isSortDescending() -> Bool
}

public protocol LabelFactory {
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment, isSortColumn: Bool) -> NSTextField
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField
    func createProcessDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField
    func createRowLabel(text: String, frame: NSRect, alignment: NSTextAlignment) -> NSTextField
}

public protocol BackgroundStylist {
    func addTableBackground(to section: NSView, padding: CGFloat)
}

public protocol SortHandler: AnyObject {
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool)
}


public struct TableStyling {
    public static let tableBackgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public static let alternateRowColor = CGColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    public static let headerBackgroundColor = NSColor(calibratedWhite: 0.25, alpha: 1.0)
    public static let headerTextColor = NSColor.white
    public static let sectionTitleColor = ColorTheme.alwaysDarkText
    public static let dataTextColor = ColorTheme.alwaysDarkText
    public static let processTextColor = ColorTheme.alwaysDarkText
    public static let borderColor = ColorTheme.borderColor
}

public struct ColorTheme {
    public static let headerBackground = NSColor(name: "HeaderBackground") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedWhite: 0.85, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedWhite: 0.25, alpha: 1.0)
        default:
            return NSColor(calibratedWhite: 0.85, alpha: 1.0)
        }
    }
    
    public static let sectionTitle = NSColor(name: "SectionTitle") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        default:
            return NSColor.labelColor
        }
    }
    
    public static let normalMemoryPressure = NSColor(name: "NormalPressure") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        default:
            return NSColor.systemGreen
        }
    }
    
    public static let warningMemoryPressure = NSColor(name: "WarningPressure") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        default:
            return NSColor.systemYellow
        }
    }
    
    public static let criticalMemoryPressure = NSColor(name: "CriticalPressure") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        default:
            return NSColor.systemRed
        }
    }
    
    public static let highCPU = NSColor(name: "HighCPU") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        default:
            return NSColor.systemRed
        }
    }
    
    public static let mediumCPU = NSColor(name: "MediumCPU") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.9, green: 0.6, blue: 0.0, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.7, blue: 0.2, alpha: 1.0)
        default:
            return NSColor.systemOrange
        }
    }
    
    public static let lowCPU = NSColor(name: "LowCPU") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor.labelColor
        case .darkAqua, .vibrantDark:
            return NSColor.labelColor
        default:
            return NSColor.labelColor
        }
    }
    
    public static let borderColor = NSColor(name: "BorderColor") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedWhite: 0.7, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedWhite: 0.35, alpha: 1.0)
        default:
            return NSColor.separatorColor
        }
    }
    
    public static let alternateRowBackground = NSColor(calibratedWhite: 0.97, alpha: 1.0)
    
    public static let processRowText = NSColor.black
    
    public static let tableBackground = NSColor.white
    
    public static let tableText = NSColor.black
    
    public static let tableHeaderBackground = NSColor(calibratedWhite: 0.25, alpha: 1.0)
    
    public static let alwaysDarkText = NSColor.black
    
    public static let tableHeaderText = NSColor.white
}

public class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    public var customBackgroundColor: NSColor?
    public var customBorderColor: NSColor?
    
    public override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let newRect = super.drawingRect(forBounds: rect)
        let textSize = self.cellSize(forBounds: rect)
        let heightDelta = newRect.size.height - textSize.height
        if heightDelta > 0 {
            return NSRect(x: newRect.origin.x, y: newRect.origin.y + (heightDelta / 2), width: newRect.size.width, height: textSize.height)
        }
        return newRect
    }
    
    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let bgColor = customBackgroundColor {
            bgColor.setFill()
            cellFrame.fill()
        }
        
        if let borderColor = customBorderColor {
            borderColor.setStroke()
            let borderPath = NSBezierPath(rect: cellFrame)
            borderPath.lineWidth = 1.0
            borderPath.stroke()
        }
        
        super.draw(withFrame: cellFrame, in: controlView)
    }
}

open class BaseTableSection {
    public let title: String
    public let height: CGFloat
    public let yPosition: CGFloat
    public var sectionView: NSView?
    public var dataLabels: [NSTextField] = []
    
    public weak var delegate: TableSectionDelegate?
    public weak var containerView: NSView?
    
    public init(title: String, height: CGFloat, yPosition: CGFloat) {
        self.title = title
        self.height = height
        self.yPosition = yPosition
    }
    
    open func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth: CGFloat = 750
        let xPosition = (containerView.bounds.width - sectionWidth) / 2
        
        let section = NSView(frame: NSRect(x: xPosition, y: yPosition, width: sectionWidth, height: height))
        section.wantsLayer = true
        containerView.addSubview(section)
        self.sectionView = section
        
        delegate.addTableBackground(to: section, padding: 3)
        createSectionTitle()
        createHeaders()
        createDataFields()
    }
    
    open func createSectionTitle() {
        guard let section = sectionView else { return }
        
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: getTitleFontSize(), weight: .bold)
        titleLabel.textColor = NSColor.labelColor
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: getTitleXPosition(), y: getTitleYPosition(), width: 200, height: 26)
        section.addSubview(titleLabel)
    }
    
    open func createHeaders() {
    }
    
    open func createDataFields() {
    }
    
    open func updateData(with stats: MemoryStats) {
    }
    
    open func getTitleFontSize() -> CGFloat {
        return 20
    }
    
    open func getTitleXPosition() -> CGFloat {
        return 0
    }
    
    open func getTitleYPosition() -> CGFloat {
        return 0
    }
}