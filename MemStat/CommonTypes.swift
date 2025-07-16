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
    public let totalMemory: UInt64
    public let usedMemory: UInt64
    public let freeMemory: UInt64
    public let memoryPressure: String
    public let activeMemory: UInt64
    public let inactiveMemory: UInt64
    public let wiredMemory: UInt64
    public let compressedMemory: UInt64
    public let appPhysicalMemory: UInt64
    public let appVirtualMemory: UInt64
    public let anonymousMemory: UInt64
    public let fileBackedMemory: UInt64
    public let swapTotalMemory: UInt64
    public let swapUsedMemory: UInt64
    public let swapFreeMemory: UInt64
    public let swapUtilization: Double
    public let swapIns: UInt64
    public let swapOuts: UInt64
    public let topProcesses: [ProcessInfo]
    
    public init(totalMemory: UInt64, usedMemory: UInt64, freeMemory: UInt64, memoryPressure: String,
                activeMemory: UInt64, inactiveMemory: UInt64, wiredMemory: UInt64, compressedMemory: UInt64,
                appPhysicalMemory: UInt64, appVirtualMemory: UInt64, anonymousMemory: UInt64, fileBackedMemory: UInt64,
                swapTotalMemory: UInt64, swapUsedMemory: UInt64, swapFreeMemory: UInt64, swapUtilization: Double,
                swapIns: UInt64, swapOuts: UInt64, topProcesses: [ProcessInfo]) {
        self.totalMemory = totalMemory
        self.usedMemory = usedMemory
        self.freeMemory = freeMemory
        self.memoryPressure = memoryPressure
        self.activeMemory = activeMemory
        self.inactiveMemory = inactiveMemory
        self.wiredMemory = wiredMemory
        self.compressedMemory = compressedMemory
        self.appPhysicalMemory = appPhysicalMemory
        self.appVirtualMemory = appVirtualMemory
        self.anonymousMemory = anonymousMemory
        self.fileBackedMemory = fileBackedMemory
        self.swapTotalMemory = swapTotalMemory
        self.swapUsedMemory = swapUsedMemory
        self.swapFreeMemory = swapFreeMemory
        self.swapUtilization = swapUtilization
        self.swapIns = swapIns
        self.swapOuts = swapOuts
        self.topProcesses = topProcesses
    }
}

public struct VerticalTableLayout {
    public static let memoryTableWidth: CGFloat = 229
    public static let virtualTableWidth: CGFloat = 252
    public static let swapTableWidth: CGFloat = 229
    public static let tableSpacing: CGFloat = 20
    public static let sectionTitleHeight: CGFloat = 26
    public static let rowHeight: CGFloat = 22
    public static let rowSpacing: CGFloat = 2
    public static let labelWidth: CGFloat = 90
    public static let valueWidth: CGFloat = 100
    public static let unitWidth: CGFloat = 30
    public static let leftMargin: CGFloat = 10
    public static let rightMargin: CGFloat = 0
    public static let labelValueSpacing: CGFloat = 20  // Space between labels and values
    public static let topMargin: CGFloat = rowHeight  // Space from window top to tables (1 row)
    public static let tableProcessSpacing: CGFloat = 25  // Space between top tables and process table
    public static let processTableHeight: CGFloat = 452  // Height of the process table
    public static let bottomMargin: CGFloat = rowHeight  // Space from process table to window bottom (1 row)
    public static let sectionSpacing: CGFloat = 20  // Space between sections
    
    public static func memoryTableX(containerWidth: CGFloat) -> CGFloat {
        // Align with left edge of Process table (750px width, centered)
        return (containerWidth - 750) / 2
    }
    
    public static func virtualTableX(containerWidth: CGFloat) -> CGFloat {
        return memoryTableX(containerWidth: containerWidth) + memoryTableWidth + tableSpacing
    }
    
    public static func swapTableX(containerWidth: CGFloat) -> CGFloat {
        return virtualTableX(containerWidth: containerWidth) + virtualTableWidth + tableSpacing
    }
    
    public static func sectionTitleY(sectionHeight: CGFloat) -> CGFloat {
        return sectionHeight - sectionTitleHeight
    }
    
    public static func rowY(rowIndex: Int, sectionHeight: CGFloat) -> CGFloat {
        return sectionHeight - sectionTitleHeight - CGFloat(rowIndex + 1) * (rowHeight + rowSpacing)
    }
    
    public static func labelX() -> CGFloat {
        return leftMargin
    }
    
    public static func valueX() -> CGFloat {
        return labelWidth + labelValueSpacing
    }
    
    public static func unitX() -> CGFloat {
        return valueX() + valueWidth - unitWidth
    }
    
    public static func calculateTableHeight(for numberOfRows: Int) -> CGFloat {
        return sectionTitleHeight + CGFloat(numberOfRows) * (rowHeight + rowSpacing) + rowSpacing
    }
}

public protocol TableSectionDelegate: LabelFactory, BackgroundStylist, SortHandler {
}

public protocol LabelFactory {
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField
}

public protocol BackgroundStylist {
    func addTableBackground(to section: NSView, padding: CGFloat)
}

public protocol SortHandler: AnyObject {
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool)
}

public struct ColumnConfig {
    public let title: String
    public let width: CGFloat
    public let alignment: NSTextAlignment
    public let hasUnits: Bool
    public let isDarkBackground: Bool
    public let sortColumn: ProcessSortColumn?
    
    public init(title: String, width: CGFloat, alignment: NSTextAlignment = .right, hasUnits: Bool = true, isDarkBackground: Bool = true, sortColumn: ProcessSortColumn? = nil) {
        self.title = title
        self.width = width
        self.alignment = alignment
        self.hasUnits = hasUnits
        self.isDarkBackground = isDarkBackground
        self.sortColumn = sortColumn
    }
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
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = getColumnConfigurations()
        for (index, column) in columns.enumerated() {
            let headerFrame = NSRect(
                x: getHeaderX(for: index),
                y: getHeaderY(),
                width: column.width,
                height: 26
            )
            
            let headerLabel = delegate.createHeaderLabel(
                column.title,
                frame: headerFrame,
                isDarkBackground: column.isDarkBackground,
                sortColumn: column.sortColumn,
                fontSize: 14,
                alignment: column.alignment
            )
            
            section.addSubview(headerLabel)
        }
    }
    
    open func createDataFields() {
    }
    
    open func updateData(with stats: MemoryStats) {
    }
    
    open func getColumnConfigurations() -> [ColumnConfig] {
        return []
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
    
    open func getHeaderX(for index: Int) -> CGFloat {
        return 0
    }
    
    open func getHeaderY() -> CGFloat {
        return 0
    }
    
    open func getDataY() -> CGFloat {
        return 0
    }
}