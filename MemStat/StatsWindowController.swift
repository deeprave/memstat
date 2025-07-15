import Cocoa

struct TableStyling {
    static let tableBackgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let alternateRowColor = CGColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    static let headerBackgroundColor = NSColor(calibratedWhite: 0.25, alpha: 1.0)
    static let headerTextColor = NSColor.white
    static let sectionTitleColor = ColorTheme.alwaysDarkText
    static let dataTextColor = ColorTheme.alwaysDarkText
    static let processTextColor = ColorTheme.alwaysDarkText
    static let borderColor = ColorTheme.borderColor
}

struct ColorTheme {
    static let headerBackground = NSColor(name: "HeaderBackground") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedWhite: 0.85, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedWhite: 0.25, alpha: 1.0)
        default:
            return NSColor(calibratedWhite: 0.85, alpha: 1.0)
        }
    }
    
    static let sectionTitle = NSColor(name: "SectionTitle") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        default:
            return NSColor.labelColor
        }
    }
    
    static let normalMemoryPressure = NSColor(name: "NormalPressure") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        default:
            return NSColor.systemGreen
        }
    }
    
    static let warningMemoryPressure = NSColor(name: "WarningPressure") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        default:
            return NSColor.systemYellow
        }
    }
    
    static let criticalMemoryPressure = NSColor(name: "CriticalPressure") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        default:
            return NSColor.systemRed
        }
    }
    
    static let highCPU = NSColor(name: "HighCPU") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        default:
            return NSColor.systemRed
        }
    }
    
    static let mediumCPU = NSColor(name: "MediumCPU") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedRed: 0.9, green: 0.6, blue: 0.0, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedRed: 1.0, green: 0.7, blue: 0.2, alpha: 1.0)
        default:
            return NSColor.systemOrange
        }
    }
    
    static let lowCPU = NSColor(name: "LowCPU") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor.labelColor
        case .darkAqua, .vibrantDark:
            return NSColor.labelColor
        default:
            return NSColor.labelColor
        }
    }
    
    static let borderColor = NSColor(name: "BorderColor") { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight:
            return NSColor(calibratedWhite: 0.7, alpha: 1.0)
        case .darkAqua, .vibrantDark:
            return NSColor(calibratedWhite: 0.35, alpha: 1.0)
        default:
            return NSColor.separatorColor
        }
    }
    
    static let alternateRowBackground = NSColor(calibratedWhite: 0.97, alpha: 1.0)
    
    static let processRowText = NSColor.black
    
    static let tableBackground = NSColor.white
    
    static let tableText = NSColor.black
    
    static let tableHeaderBackground = NSColor(calibratedWhite: 0.25, alpha: 1.0)
    
    static let alwaysDarkText = NSColor.black
    
    static let tableHeaderText = NSColor.white
}

class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    var customBackgroundColor: NSColor?
    var customBorderColor: NSColor?
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let newRect = super.drawingRect(forBounds: rect)
        let textSize = self.cellSize(forBounds: rect)
        let heightDelta = newRect.size.height - textSize.height
        if heightDelta > 0 {
            return NSRect(x: newRect.origin.x, y: newRect.origin.y + (heightDelta / 2), width: newRect.size.width, height: textSize.height)
        }
        return newRect
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
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

struct ProcessTableColumn {
    let title: String
    let width: CGFloat
    let sortColumn: ProcessSortColumn
    let alignment: NSTextAlignment
    
    init(title: String, width: CGFloat, sortColumn: ProcessSortColumn, alignment: NSTextAlignment = .center) {
        self.title = title
        self.width = width
        self.sortColumn = sortColumn
        self.alignment = alignment
    }
}

struct StandardTableLayout {
    static let sectionTitleLeftMargin: CGFloat = 102
    static let headerStartX: CGFloat = 187
    static let dataStartX: CGFloat = 192
    static let columnWidth: CGFloat = 120
    static let lastColumnWidth: CGFloat = 100
    static let unitWidth: CGFloat = 30
    static let unitOffsetX: CGFloat = 2
    static let headerHeight: CGFloat = 26
    static let dataRowHeight: CGFloat = 22
    
    static func sectionTitleY(sectionHeight: CGFloat) -> CGFloat {
        return sectionHeight - headerHeight
    }
    
    static func headerY(sectionHeight: CGFloat) -> CGFloat {
        return sectionHeight - headerHeight
    }
    
    static func dataY() -> CGFloat {
        return 1
    }
    
    static func swapSectionTitleY() -> CGFloat {
        return 51
    }
    
    static func swapHeaderY() -> CGFloat {
        return 51
    }
    
    static func swapFirstDataY() -> CGFloat {
        return 26
    }
    
    static func swapSecondDataY() -> CGFloat {
        return 1
    }
    
    static func columnX(for index: Int) -> CGFloat {
        return headerStartX + (CGFloat(index) * columnWidth)
    }
    
    static func dataColumnX(for index: Int) -> CGFloat {
        return dataStartX + (CGFloat(index) * columnWidth)
    }
    
    static func unitX(for index: Int) -> CGFloat {
        let columnEndX = dataColumnX(for: index) + (index < 3 ? columnWidth : lastColumnWidth)
        return columnEndX - unitWidth - 5
    }
    
    static func valueX(for index: Int) -> CGFloat {
        return unitX(for: index) - unitOffsetX
    }
    
    static func valueWidth(for index: Int) -> CGFloat {
        return valueX(for: index) - dataColumnX(for: index)
    }
    
    static func valueWidthNoUnits(for index: Int) -> CGFloat {
        return index < 3 ? columnWidth : lastColumnWidth
    }
}

struct ProcessTableLayout {
    static let columns: [ProcessTableColumn] = [
        ProcessTableColumn(title: "PID", width: 70, sortColumn: .pid, alignment: .right),
        ProcessTableColumn(title: "%Mem", width: 75, sortColumn: .memoryPercent, alignment: .right),
        ProcessTableColumn(title: "Mem(MB)", width: 95, sortColumn: .memoryBytes, alignment: .right),
        ProcessTableColumn(title: "VMem(MB)", width: 120, sortColumn: .virtualMemory, alignment: .right),
        ProcessTableColumn(title: "%CPU", width: 70, sortColumn: .cpuPercent, alignment: .right),
        ProcessTableColumn(title: "Command", width: 320, sortColumn: .command, alignment: .left)
    ]
    
    static let headerY: CGFloat = 391
    static let dataStartY: CGFloat = 365  // First data row
    static let dataRowHeight: CGFloat = 19
    static let sectionTitleY: CGFloat = 426
    
    static func xPosition(for columnIndex: Int) -> CGFloat {
        var x: CGFloat = 0
        for i in 0..<columnIndex {
            x += columns[i].width
        }
        return x
    }
    
    static func column(at index: Int) -> ProcessTableColumn {
        return columns[index]
    }
}

struct ColumnConfig {
    let title: String
    let width: CGFloat
    let alignment: NSTextAlignment
    let hasUnits: Bool
    let isDarkBackground: Bool
    let sortColumn: ProcessSortColumn?
    
    init(title: String, width: CGFloat, alignment: NSTextAlignment = .right, hasUnits: Bool = true, isDarkBackground: Bool = true, sortColumn: ProcessSortColumn? = nil) {
        self.title = title
        self.width = width
        self.alignment = alignment
        self.hasUnits = hasUnits
        self.isDarkBackground = isDarkBackground
        self.sortColumn = sortColumn
    }
}

protocol TableSectionDelegate: AnyObject {
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField
    func addTableBackground(to section: NSView, padding: CGFloat)
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool)
}

class BaseTableSection {
    let title: String
    let height: CGFloat
    let yPosition: CGFloat
    var sectionView: NSView?
    var dataLabels: [NSTextField] = []
    
    weak var delegate: TableSectionDelegate?
    weak var containerView: NSView?
    
    init(title: String, height: CGFloat, yPosition: CGFloat) {
        self.title = title
        self.height = height
        self.yPosition = yPosition
    }
    
    func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
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
    
    private func createSectionTitle() {
        guard let section = sectionView else { return }
        
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: getTitleFontSize(), weight: .bold)
        titleLabel.textColor = ColorTheme.alwaysDarkText
        titleLabel.frame = NSRect(x: getTitleXPosition(), y: getTitleYPosition(), width: 200, height: StandardTableLayout.headerHeight)
        section.addSubview(titleLabel)
    }
    
    func createHeaders() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = getColumnConfigurations()
        for (index, column) in columns.enumerated() {
            let headerFrame = NSRect(
                x: getHeaderX(for: index),
                y: getHeaderY(),
                width: column.width,
                height: StandardTableLayout.headerHeight
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
    
    func createDataFields() {
    }
    
    func updateData(with stats: MemoryStats) {
    }
    
    func getColumnConfigurations() -> [ColumnConfig] {
        return []
    }
    
    func getTitleFontSize() -> CGFloat {
        return 18
    }
    
    func getTitleXPosition() -> CGFloat {
        return StandardTableLayout.sectionTitleLeftMargin
    }
    
    func getTitleYPosition() -> CGFloat {
        return StandardTableLayout.sectionTitleY(sectionHeight: height)
    }
    
    func getHeaderX(for index: Int) -> CGFloat {
        return StandardTableLayout.columnX(for: index)
    }
    
    func getHeaderY() -> CGFloat {
        return StandardTableLayout.headerY(sectionHeight: height)
    }
    
    func getDataY() -> CGFloat {
        return StandardTableLayout.dataY()
    }
}

class MemoryTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Memory", height: 50, yPosition: yPosition)
    }
    
    override func getColumnConfigurations() -> [ColumnConfig] {
        return [
            ColumnConfig(title: "Total", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Used", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Free", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Pressure", width: StandardTableLayout.lastColumnWidth, hasUnits: false)
        ]
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = getColumnConfigurations()
        for (index, column) in columns.enumerated() {
            if column.hasUnits {
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: StandardTableLayout.dataColumnX(for: index),
                        y: getDataY(),
                        width: StandardTableLayout.valueWidth(for: index),
                        height: StandardTableLayout.dataRowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                let unitLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(
                        x: StandardTableLayout.unitX(for: index),
                        y: getDataY(),
                        width: StandardTableLayout.unitWidth,
                        height: StandardTableLayout.dataRowHeight
                    ),
                    alignment: .left,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                section.addSubview(unitLabel)
                dataLabels.append(valueLabel)
                dataLabels.append(unitLabel)
            } else {
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: StandardTableLayout.dataColumnX(for: index),
                        y: getDataY(),
                        width: StandardTableLayout.valueWidthNoUnits(for: index),
                        height: StandardTableLayout.dataRowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                dataLabels.append(valueLabel)
            }
        }
    }
    
    override func updateData(with stats: MemoryStats) {
        guard dataLabels.count >= 7 else { return }
        
        let formatters = [
            { FormatUtilities.formatBytes(stats.totalMemory) },
            { FormatUtilities.formatBytes(stats.usedMemory) },
            { FormatUtilities.formatBytes(stats.freeMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = FormatUtilities.separateValueAndUnit(formatted)
            let labelIndex = index * 2
            
            dataLabels[labelIndex].stringValue = parts.value
            dataLabels[labelIndex + 1].stringValue = parts.unit
        }
        
        dataLabels[6].stringValue = stats.memoryPressure
        
        switch stats.memoryPressure {
        case "Normal":
            dataLabels[6].textColor = ColorTheme.normalMemoryPressure
        case "Warning":
            dataLabels[6].textColor = ColorTheme.warningMemoryPressure
        case "Critical":
            dataLabels[6].textColor = ColorTheme.criticalMemoryPressure
        default:
            dataLabels[6].textColor = NSColor.labelColor
        }
    }
    
}

class VirtualTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Virtual", height: 50, yPosition: yPosition)
    }
    
    override func getColumnConfigurations() -> [ColumnConfig] {
        return [
            ColumnConfig(title: "Active", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Inactive", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Wired", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Compressed", width: StandardTableLayout.lastColumnWidth)
        ]
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = getColumnConfigurations()
        for (index, _) in columns.enumerated() {
            let valueLabel = delegate.createDataLabel(
                text: "Loading...",
                frame: NSRect(
                    x: StandardTableLayout.dataColumnX(for: index),
                    y: getDataY(),
                    width: StandardTableLayout.valueWidth(for: index),
                    height: StandardTableLayout.dataRowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            
            let unitLabel = delegate.createDataLabel(
                text: "",
                frame: NSRect(
                    x: StandardTableLayout.unitX(for: index),
                    y: getDataY(),
                    width: StandardTableLayout.unitWidth,
                    height: StandardTableLayout.dataRowHeight
                ),
                alignment: .left,
                useMonospacedFont: false
            )
            
            section.addSubview(valueLabel)
            section.addSubview(unitLabel)
            dataLabels.append(valueLabel)
            dataLabels.append(unitLabel)
        }
    }
    
    override func updateData(with stats: MemoryStats) {
        guard dataLabels.count >= 8 else { return }
        
        let formatters = [
            { FormatUtilities.formatBytes(stats.activeMemory) },
            { FormatUtilities.formatBytes(stats.inactiveMemory) },
            { FormatUtilities.formatBytes(stats.wiredMemory) },
            { FormatUtilities.formatBytes(stats.compressedMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = FormatUtilities.separateValueAndUnit(formatted)
            let labelIndex = index * 2
            
            dataLabels[labelIndex].stringValue = parts.value
            dataLabels[labelIndex + 1].stringValue = parts.unit
        }
    }
    
}

class SwapTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Swap", height: 75, yPosition: yPosition)
    }
    
    override func getColumnConfigurations() -> [ColumnConfig] {
        return [
            ColumnConfig(title: "Total", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Used", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Free", width: StandardTableLayout.columnWidth),
            ColumnConfig(title: "Util", width: StandardTableLayout.lastColumnWidth, hasUnits: false)
        ]
    }
    
    override func getTitleYPosition() -> CGFloat {
        return StandardTableLayout.swapSectionTitleY()
    }
    
    override func getHeaderY() -> CGFloat {
        return StandardTableLayout.swapHeaderY()
    }
    
    override func getDataY() -> CGFloat {
        return StandardTableLayout.swapFirstDataY()
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = getColumnConfigurations()
        for (index, column) in columns.enumerated() {
            if column.hasUnits {
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: StandardTableLayout.dataColumnX(for: index),
                        y: getDataY(),
                        width: StandardTableLayout.valueWidth(for: index),
                        height: StandardTableLayout.dataRowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                let unitLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(
                        x: StandardTableLayout.unitX(for: index),
                        y: getDataY(),
                        width: StandardTableLayout.unitWidth,
                        height: StandardTableLayout.dataRowHeight
                    ),
                    alignment: .left,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                section.addSubview(unitLabel)
                dataLabels.append(valueLabel)
                dataLabels.append(unitLabel)
            } else {
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: StandardTableLayout.dataColumnX(for: index),
                        y: getDataY(),
                        width: StandardTableLayout.valueWidthNoUnits(for: index),
                        height: StandardTableLayout.dataRowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                dataLabels.append(valueLabel)
            }
        }
        
        createSwapInOutLabels()
    }
    
    private func createSwapInOutLabels() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let swapInLabel = delegate.createHeaderLabel(
            "Swap Ins",
            frame: NSRect(
                x: StandardTableLayout.dataColumnX(for: 0),
                y: StandardTableLayout.swapSecondDataY(),
                width: 110,
                height: StandardTableLayout.dataRowHeight
            ),
            isDarkBackground: true,
            sortColumn: nil,
            fontSize: 17,
            alignment: .right
        )
        section.addSubview(swapInLabel)
        
        let swapOutLabel = delegate.createHeaderLabel(
            "Swap Outs",
            frame: NSRect(
                x: StandardTableLayout.dataColumnX(for: 2),
                y: StandardTableLayout.swapSecondDataY(),
                width: 110,
                height: StandardTableLayout.dataRowHeight
            ),
            isDarkBackground: true,
            sortColumn: nil,
            fontSize: 17,
            alignment: .right
        )
        section.addSubview(swapOutLabel)
        
        let swapInValueLabel = delegate.createDataLabel(
            text: "Loading...",
            frame: NSRect(
                x: StandardTableLayout.dataColumnX(for: 1),
                y: StandardTableLayout.swapSecondDataY(),
                width: 110,
                height: StandardTableLayout.dataRowHeight
            ),
            alignment: .right,
            useMonospacedFont: false
        )
        section.addSubview(swapInValueLabel)
        dataLabels.append(swapInValueLabel)
        
        let swapOutValueLabel = delegate.createDataLabel(
            text: "Loading...",
            frame: NSRect(
                x: StandardTableLayout.dataColumnX(for: 3),
                y: StandardTableLayout.swapSecondDataY(),
                width: StandardTableLayout.valueWidthNoUnits(for: 3),
                height: StandardTableLayout.dataRowHeight
            ),
            alignment: .right,
            useMonospacedFont: false
        )
        section.addSubview(swapOutValueLabel)
        dataLabels.append(swapOutValueLabel)
    }
    
    override func updateData(with stats: MemoryStats) {
        guard dataLabels.count >= 9 else { return }
        
        let formatters = [
            { FormatUtilities.formatBytes(stats.swapTotalMemory) },
            { FormatUtilities.formatBytes(stats.swapUsedMemory) },
            { FormatUtilities.formatBytes(stats.swapFreeMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = FormatUtilities.separateValueAndUnit(formatted)
            let labelIndex = index * 2
            
            dataLabels[labelIndex].stringValue = parts.value
            dataLabels[labelIndex + 1].stringValue = parts.unit
        }
        
        dataLabels[6].stringValue = String(format: "%.1f%%", stats.swapUtilization)
        
        if stats.swapUtilization > 80.0 {
            dataLabels[6].textColor = ColorTheme.criticalMemoryPressure
        } else if stats.swapUtilization > 50.0 {
            dataLabels[6].textColor = ColorTheme.warningMemoryPressure
        } else {
            dataLabels[6].textColor = NSColor.labelColor
        }
        
        dataLabels[7].stringValue = FormatUtilities.formatCount(stats.swapIns)
        dataLabels[8].stringValue = FormatUtilities.formatCount(stats.swapOuts)
    }
    
    
}

class ProcessTableSection: BaseTableSection {
    private var processHeaderLabels: [ProcessSortColumn: NSTextField] = [:]
    private var currentSortColumn: ProcessSortColumn = .memoryPercent
    private var sortDescending: Bool = true
    
    init(yPosition: CGFloat) {
        super.init(title: "Top Processes", height: 452, yPosition: yPosition)
    }
    
    override func getTitleFontSize() -> CGFloat {
        return 22
    }
    
    override func getTitleXPosition() -> CGFloat {
        return 0
    }
    
    override func getTitleYPosition() -> CGFloat {
        return ProcessTableLayout.sectionTitleY
    }
    
    override func getColumnConfigurations() -> [ColumnConfig] {
        return ProcessTableLayout.columns.map { column in
            ColumnConfig(
                title: column.title,
                width: column.width,
                alignment: column.alignment,
                hasUnits: false,
                isDarkBackground: true,
                sortColumn: column.sortColumn
            )
        }
    }
    
    override func createHeaders() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = ProcessTableLayout.columns
        for (index, column) in columns.enumerated() {
            let x = ProcessTableLayout.xPosition(for: index)
            let frame = NSRect(x: x, y: ProcessTableLayout.headerY, width: column.width, height: 26)
            
            let headerLabel = delegate.createHeaderLabel(
                column.title,
                frame: frame,
                isDarkBackground: true,
                sortColumn: column.sortColumn,
                fontSize: 12,
                alignment: column.alignment
            )
            
            processHeaderLabels[column.sortColumn] = headerLabel
            
            let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleHeaderClick))
            headerLabel.addGestureRecognizer(clickGesture)
            
            section.addSubview(headerLabel)
        }
        
        updateAllProcessHeaders()
        createBorders()
    }
    
    private func createBorders() {
        guard let section = sectionView else { return }
        
        for i in 1..<ProcessTableLayout.columns.count {
            let x = ProcessTableLayout.xPosition(for: i)
            let border = NSView(frame: NSRect(x: x, y: 5, width: 1, height: 392))
            border.wantsLayer = true
            border.layer?.backgroundColor = ColorTheme.borderColor.cgColor
            section.addSubview(border)
        }
        
        let bottomBorder = NSView(frame: NSRect(x: 0, y: 0, width: 750, height: 1))
        bottomBorder.wantsLayer = true
        bottomBorder.layer?.backgroundColor = ColorTheme.borderColor.cgColor
        section.addSubview(bottomBorder)
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        for i in 0..<20 {
            let yPos = ProcessTableLayout.dataStartY - (CGFloat(i) * ProcessTableLayout.dataRowHeight)
            
            for (columnIndex, column) in ProcessTableLayout.columns.enumerated() {
                let x = ProcessTableLayout.xPosition(for: columnIndex)
                let dataWidth = column.width - 10
                let dataX = x + 5
                
                let valueLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(x: dataX, y: yPos, width: dataWidth, height: 19),
                    alignment: column.alignment,
                    useMonospacedFont: true
                )
                
                if column.sortColumn == .command {
                    valueLabel.cell?.truncatesLastVisibleLine = true
                }
                
                section.addSubview(valueLabel)
                dataLabels.append(valueLabel)
            }
        }
    }
    
    override func updateData(with stats: MemoryStats) {
        for i in 0..<20 {
            let baseIndex = i * 6
            if i < stats.topProcesses.count {
                let process = stats.topProcesses[i]
                
                dataLabels[baseIndex].stringValue = String(process.pid)
                dataLabels[baseIndex + 1].stringValue = String(format: "%.1f", process.memoryPercent)
                dataLabels[baseIndex + 2].stringValue = String(Int(process.memoryBytes / 1024 / 1024))
                dataLabels[baseIndex + 3].stringValue = String(Int(process.virtualMemoryBytes / 1024 / 1024))
                dataLabels[baseIndex + 4].stringValue = String(format: "%.2f", process.cpuPercent)
                dataLabels[baseIndex + 5].stringValue = process.command
                
                for j in 0..<6 {
                    dataLabels[baseIndex + j].textColor = ColorTheme.alwaysDarkText
                }
            } else {
                for j in 0..<6 {
                    dataLabels[baseIndex + j].stringValue = ""
                }
            }
        }
    }
    
    @objc private func handleHeaderClick(_ sender: NSClickGestureRecognizer) {
        guard let headerLabel = sender.view as? NSTextField else { return }
        
        var clickedColumn: ProcessSortColumn?
        
        for (sortColumn, label) in processHeaderLabels {
            if label === headerLabel {
                clickedColumn = sortColumn
                break
            }
        }
        
        guard let column = clickedColumn else { return }
        
        if column == currentSortColumn {
            sortDescending.toggle()
        } else {
            currentSortColumn = column
            sortDescending = (column != .command)
        }
        
        updateAllProcessHeaders()
        
        delegate?.updateSortingAndRefresh(sortColumn: currentSortColumn, sortDescending: sortDescending)
    }
    
    private func updateAllProcessHeaders() {
        updateProcessHeaderForSortColumn(.pid, title: "PID")
        updateProcessHeaderForSortColumn(.memoryPercent, title: "%Mem")
        updateProcessHeaderForSortColumn(.memoryBytes, title: "Mem(MB)")
        updateProcessHeaderForSortColumn(.virtualMemory, title: "VMem(MB)")
        updateProcessHeaderForSortColumn(.cpuPercent, title: "%CPU")
        updateProcessHeaderForSortColumn(.command, title: "Command")
    }
    
    private func updateProcessHeaderForSortColumn(_ sortColumn: ProcessSortColumn, title: String) {
        guard let label = processHeaderLabels[sortColumn] else { return }
        
        let isActiveSort = sortColumn == currentSortColumn
        
        let displayText = FormatUtilities.createSortableHeaderText(title, sortColumn: sortColumn, currentSortColumn: currentSortColumn, sortDescending: sortDescending)
        label.stringValue = displayText
        
        if isActiveSort {
            label.textColor = NSColor.systemYellow
        } else {
            label.textColor = TableStyling.headerTextColor
        }
        
        if let cell = label.cell as? VerticallyCenteredTextFieldCell {
            if isActiveSort {
                cell.textColor = NSColor.systemYellow
            } else {
                cell.textColor = TableStyling.headerTextColor
            }
        }
    }
    
}

class StatsWindowController: NSWindowController, TableSectionDelegate {
    
    private var memoryMonitor: MemoryMonitor!
    private var statsView: NSView!
    private var timer: Timer?
    private var appearanceObserver: NSObjectProtocol?
    
    private var tableSections: [BaseTableSection] = []
    private var currentSortColumn: ProcessSortColumn = .memoryPercent
    private var sortDescending: Bool = true
    
    override init(window: NSWindow?) {
        super.init(window: window)
        setupWindow()
        setupMemoryMonitor()
        setupAppearanceObserver()
    }
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 794, height: 737),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWindow() {
        guard let window = window else { return }
        
        window.level = .floating
        window.backgroundColor = NSColor.controlBackgroundColor
        window.hasShadow = true
        window.isOpaque = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 10
        window.contentView?.layer?.masksToBounds = false
        
        setupStatsView()
    }
    
    
    
    
    private func setupStatsView() {
        guard let window = window else { return }
        
        statsView = NSView(frame: window.contentView!.bounds)
        statsView.autoresizingMask = [.width, .height]
        statsView.wantsLayer = true
        statsView.layer?.masksToBounds = false
        window.contentView?.addSubview(statsView)
        
        createTableSections()
        setupTableSections()
    }
    
    private func createTableSections() {
        let windowHeight = statsView.bounds.height
        
        let memorySection = MemoryTableSection(yPosition: windowHeight - 22 - 50)
        let virtualSection = VirtualTableSection(yPosition: windowHeight - 94 - 50)
        let swapSection = SwapTableSection(yPosition: windowHeight - 166 - 75)
        let processSection = ProcessTableSection(yPosition: windowHeight - 263 - 452)
        
        tableSections = [memorySection, virtualSection, swapSection, processSection]
    }
    
    private func setupTableSections() {
        for section in tableSections {
            section.setupSection(in: statsView, delegate: self)
        }
        
// applyTableTextColors() - now handled by individual table sections
    }
    
    // MARK: - TableSectionDelegate
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField {
        // Create the text with sorting indicator if applicable
        let displayText = FormatUtilities.createSortableHeaderText(text, sortColumn: sortColumn, currentSortColumn: currentSortColumn, sortDescending: sortDescending)
        
        let label = NSTextField(frame: frame)
        label.stringValue = displayText
        label.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        label.alignment = alignment
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.backgroundColor = .clear
        label.drawsBackground = false
        
        // Use the custom cell for vertical centering
        let cell = VerticallyCenteredTextFieldCell(textCell: displayText)
        cell.font = NSFont.systemFont(ofSize: 14, weight: .bold)
        cell.alignment = alignment
        
        if isDarkBackground {
            // Check if this is the active sort column for special coloring
            let isActiveSortColumn = sortColumn != nil && sortColumn == currentSortColumn
            
            if isActiveSortColumn {
                // Bright yellow color for active sort column
                label.textColor = NSColor.systemYellow
                cell.textColor = NSColor.systemYellow
                cell.customBackgroundColor = TableStyling.headerBackgroundColor
            } else {
                // Normal header colors
                label.textColor = TableStyling.headerTextColor
                cell.textColor = TableStyling.headerTextColor
                cell.customBackgroundColor = TableStyling.headerBackgroundColor
            }
            cell.customBorderColor = TableStyling.borderColor
        } else {
            // Light background headers
            let isActiveSortColumn = sortColumn != nil && sortColumn == currentSortColumn
            
            if isActiveSortColumn {
                // Bright yellow color for active sort column
                label.textColor = NSColor.systemYellow
                cell.textColor = NSColor.systemYellow
            } else {
                // Normal text color
                label.textColor = ColorTheme.alwaysDarkText
                cell.textColor = ColorTheme.alwaysDarkText
            }
        }
        
        label.cell = cell
        
        return label
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = useMonospacedFont ? NSFont.monospacedSystemFont(ofSize: 17, weight: .regular) : NSFont.systemFont(ofSize: 17)
        label.textColor = TableStyling.dataTextColor
        label.frame = frame
        label.alignment = alignment
        return label
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        let backgroundFrame = section.bounds.insetBy(dx: -padding, dy: -padding)
        
        let shadowFrame = backgroundFrame.offsetBy(dx: 4, dy: -4) // Even larger offset for visibility
        let shadowView = NSView(frame: shadowFrame)
        shadowView.wantsLayer = true
        
        // Use different shadow colors for light/dark mode
        let shadowColor = NSColor(name: "TableShadow") { appearance in
            switch appearance.name {
            case .aqua, .vibrantLight:
                return NSColor.black.withAlphaComponent(0.25) // Dark shadow for light mode
            case .darkAqua, .vibrantDark:
                return NSColor.white.withAlphaComponent(0.4) // Much brighter white shadow for dark mode
            default:
                return NSColor.black.withAlphaComponent(0.25)
            }
        }
        
        shadowView.layer?.backgroundColor = shadowColor.cgColor
        shadowView.layer?.cornerRadius = 10.0
        shadowView.layer?.masksToBounds = true
        
        let backgroundView = NSView(frame: backgroundFrame)
        backgroundView.wantsLayer = true
        let whiteColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backgroundView.layer?.backgroundColor = whiteColor // Force pure white
        backgroundView.layer?.cornerRadius = 10.0
        backgroundView.layer?.masksToBounds = true
        
        section.addSubview(backgroundView, positioned: .below, relativeTo: nil)
        section.addSubview(shadowView, positioned: .below, relativeTo: backgroundView)
    }
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        self.currentSortColumn = sortColumn
        self.sortDescending = sortDescending
        updateStats()
    }
    
    
    
    
    
    
    
    
    
    
    private func setupMemoryMonitor() {
        memoryMonitor = MemoryMonitor()
    }
    
    
    
    
    
    private func setupAppearanceObserver() {
        // Listen for appearance changes (light/dark mode)
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NSAppearanceDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateColors()
        }
    }
    
    private func updateColors() {
        // Force redraw of all views that use custom colors
        statsView?.needsDisplay = true
        statsView?.subviews.forEach { $0.needsDisplay = true }
        
        // Update border colors, table backgrounds, and text colors
        updateBorderColors()
        updateTableBackgrounds()
        updateTextColors()
    }
    
    private func updateBorderColors() {
        // Update all border view colors
        statsView?.subviews.forEach { view in
            view.subviews.forEach { subview in
                if subview.frame.width == 1 || subview.frame.height == 1 {
                    // This is likely a border view
                    subview.layer?.backgroundColor = ColorTheme.borderColor.cgColor
                }
            }
        }
    }
    
    private func updateTableBackgrounds() {
        // Update table background colors
        statsView?.subviews.forEach { section in
            // Find the first subview which should be our background view
            if let backgroundView = section.subviews.first,
               backgroundView.layer?.cornerRadius == 10.0 {
                backgroundView.layer?.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    private func updateTextColors() {
        statsView?.subviews.forEach { section in
            let isProcessSection = section.subviews.filter { $0 is NSTextField }.count > 50
            
            section.subviews.forEach { subview in
                if let textField = subview as? NSTextField {
                    if isProcessSection {
                        if textField.cell is VerticallyCenteredTextFieldCell {
                                    if true {
                                textField.textColor = ColorTheme.tableHeaderText
                            }
                        } else if textField.stringValue == "Top Processes" {
                            textField.textColor = ColorTheme.alwaysDarkText
                        } else {
                            textField.textColor = ColorTheme.alwaysDarkText
                        }
                    } else {
                        if textField.cell is VerticallyCenteredTextFieldCell {
                            textField.textColor = ColorTheme.tableHeaderText
                        } else if textField.stringValue.contains("Memory") || textField.stringValue.contains("Virtual") || textField.stringValue.contains("Swap") {
                            textField.textColor = ColorTheme.alwaysDarkText
                        } else {
                            let pressureValues = ["Normal", "Warning", "Critical"]
                            if !pressureValues.contains(textField.stringValue) {
                                textField.textColor = ColorTheme.alwaysDarkText
                            }
                        }
                    }
                }
                if let textField = subview as? NSTextField,
                   let cell = textField.cell as? VerticallyCenteredTextFieldCell {
                    if true {
                        cell.textColor = ColorTheme.tableHeaderText
                    }
                    cell.customBackgroundColor = ColorTheme.tableHeaderBackground
                }
            }
        }
    }
    
    
    
    deinit {
        if let observer = appearanceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func showWindow(at origin: NSPoint) {
        guard let window = window else { return }
        
        window.setFrameOrigin(origin)
        window.orderFront(nil)
        
        updateStats()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    func hideWindow() {
        timer?.invalidate()
        timer = nil
        window?.orderOut(nil)
    }
    
    private func updateStats() {
        let stats = memoryMonitor.getMemoryStats(sortBy: currentSortColumn, sortDescending: sortDescending)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for section in self.tableSections {
                section.updateData(with: stats)
            }
            
        }
    }
    
    
    
}