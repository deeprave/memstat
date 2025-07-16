import Cocoa

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



class MemoryTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Memory", height: VerticalTableLayout.calculateTableHeight(for: 7), yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth = VerticalTableLayout.memoryTableWidth
        let xPosition = VerticalTableLayout.memoryTableX(containerWidth: containerView.bounds.width)
        
        let section = NSView(frame: NSRect(x: xPosition, y: yPosition, width: sectionWidth, height: height))
        section.wantsLayer = true
        containerView.addSubview(section)
        self.sectionView = section
        
        delegate.addTableBackground(to: section, padding: 3)
        createSectionTitle()
        createDataFields()
    }
    
    override func getTitleXPosition() -> CGFloat {
        return 10
    }
    
    override func getTitleYPosition() -> CGFloat {
        return VerticalTableLayout.sectionTitleY(sectionHeight: height)
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let metrics = [
            ("Total", true),
            ("Used", true),
            ("Apps", true),
            ("System", true),
            ("Cache", true),
            ("Free", true),
            ("Pressure", false)
        ]
        
        let fieldFactory = TableFieldFactory(labelFactory: delegate)
        
        for (index, (label, hasUnits)) in metrics.enumerated() {
            let fields = fieldFactory.createMetricField(
                label: label,
                hasUnits: hasUnits,
                rowIndex: index,
                sectionHeight: height,
                section: section
            )
            dataLabels.append(contentsOf: fields)
        }
    }
    
    override func updateData(with stats: MemoryStats) {
        guard dataLabels.count >= 12 else { return }
        
        let systemMemory = stats.usedMemory - stats.appPhysicalMemory
        let cacheMemory = stats.fileBackedMemory // Use file-backed memory as cache
        let formatters = [
            { FormatUtilities.formatBytes(stats.totalMemory) },
            { FormatUtilities.formatBytes(stats.usedMemory) },
            { FormatUtilities.formatBytes(stats.appPhysicalMemory) },
            { FormatUtilities.formatBytes(systemMemory) },
            { FormatUtilities.formatBytes(cacheMemory) },
            { FormatUtilities.formatBytes(stats.freeMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = FormatUtilities.separateValueAndUnit(formatted)
            let labelIndex = index * 2
            
            dataLabels[labelIndex].stringValue = parts.value
            dataLabels[labelIndex + 1].stringValue = parts.unit
        }
        
        dataLabels[12].stringValue = stats.memoryPressure
        
        switch stats.memoryPressure {
        case "Normal":
            dataLabels[12].textColor = ColorTheme.normalMemoryPressure
        case "Warning":
            dataLabels[12].textColor = ColorTheme.warningMemoryPressure
        case "Critical":
            dataLabels[12].textColor = ColorTheme.criticalMemoryPressure
        default:
            dataLabels[12].textColor = NSColor.labelColor
        }
    }
    
}

class VirtualTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Virtual", height: VerticalTableLayout.calculateTableHeight(for: 7), yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth = VerticalTableLayout.virtualTableWidth
        let xPosition = VerticalTableLayout.virtualTableX(containerWidth: containerView.bounds.width)
        
        let section = NSView(frame: NSRect(x: xPosition, y: yPosition, width: sectionWidth, height: height))
        section.wantsLayer = true
        containerView.addSubview(section)
        self.sectionView = section
        
        delegate.addTableBackground(to: section, padding: 3)
        createSectionTitle()
        createDataFields()
    }
    
    override func getTitleXPosition() -> CGFloat {
        return 10
    }
    
    override func getTitleYPosition() -> CGFloat {
        return VerticalTableLayout.sectionTitleY(sectionHeight: height)
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let metrics = [
            ("Active", true),
            ("Inactive", true),
            ("Wired", true),
            ("Compressed", true),
            ("Apps", true),
            ("Anonymous", true),
            ("File-backed", true)
        ]
        
        // Custom label width for Virtual table
        let customLabelWidth: CGFloat = 105
        
        for (index, (label, hasUnits)) in metrics.enumerated() {
            let rowY = VerticalTableLayout.rowY(rowIndex: index, sectionHeight: height)
            
            let labelView = delegate.createDataLabel(
                text: label,
                frame: NSRect(
                    x: VerticalTableLayout.labelX(),
                    y: rowY,
                    width: customLabelWidth,
                    height: VerticalTableLayout.rowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            labelView.textColor = ColorTheme.alwaysDarkText
            section.addSubview(labelView)
            
            if hasUnits {
                // Adjust value position based on custom label width
                let customValueX = customLabelWidth + VerticalTableLayout.labelValueSpacing
                
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: customValueX,
                        y: rowY,
                        width: VerticalTableLayout.valueWidth - VerticalTableLayout.unitWidth - 5 + 5,
                        height: VerticalTableLayout.rowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                // Adjust unit position based on custom value position
                let customUnitX = customValueX + (VerticalTableLayout.valueWidth - VerticalTableLayout.unitWidth - 5 + 5)
                
                let unitLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(
                        x: customUnitX,
                        y: rowY,
                        width: VerticalTableLayout.unitWidth,
                        height: VerticalTableLayout.rowHeight
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
    }
    
    override func updateData(with stats: MemoryStats) {
        guard dataLabels.count >= 14 else { return }
        
        let formatters = [
            { FormatUtilities.formatBytes(stats.activeMemory) },
            { FormatUtilities.formatBytes(stats.inactiveMemory) },
            { FormatUtilities.formatBytes(stats.wiredMemory) },
            { FormatUtilities.formatBytes(stats.compressedMemory) },
            { FormatUtilities.formatBytes(stats.appVirtualMemory) },
            { FormatUtilities.formatBytes(stats.anonymousMemory) },
            { FormatUtilities.formatBytes(stats.fileBackedMemory) }
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
        super.init(title: "Swap", height: VerticalTableLayout.calculateTableHeight(for: 7), yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth = VerticalTableLayout.swapTableWidth
        let xPosition = VerticalTableLayout.swapTableX(containerWidth: containerView.bounds.width)
        
        let section = NSView(frame: NSRect(x: xPosition, y: yPosition, width: sectionWidth, height: height))
        section.wantsLayer = true
        containerView.addSubview(section)
        self.sectionView = section
        
        delegate.addTableBackground(to: section, padding: 3)
        createSectionTitle()
        createDataFields()
    }
    
    override func getTitleXPosition() -> CGFloat {
        return 10
    }
    
    override func getTitleYPosition() -> CGFloat {
        return VerticalTableLayout.sectionTitleY(sectionHeight: height)
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let metrics = [
            ("Total", true),
            ("Used", true),
            ("Free", true),
            ("Util", false),
            ("Swap Ins", false),
            ("Swap Outs", false),
            ("Efficiency", false)
        ]
        
        for (index, (label, hasUnits)) in metrics.enumerated() {
            let rowY = VerticalTableLayout.rowY(rowIndex: index, sectionHeight: height)
            
            let labelView = delegate.createDataLabel(
                text: label,
                frame: NSRect(
                    x: VerticalTableLayout.labelX(),
                    y: rowY,
                    width: VerticalTableLayout.labelWidth,
                    height: VerticalTableLayout.rowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            labelView.textColor = ColorTheme.alwaysDarkText
            section.addSubview(labelView)
            
            if hasUnits {
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: VerticalTableLayout.valueX(),
                        y: rowY,
                        width: VerticalTableLayout.valueWidth - VerticalTableLayout.unitWidth - 5,
                        height: VerticalTableLayout.rowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                let unitLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(
                        x: VerticalTableLayout.unitX(),
                        y: rowY,
                        width: VerticalTableLayout.unitWidth,
                        height: VerticalTableLayout.rowHeight
                    ),
                    alignment: .left,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                section.addSubview(unitLabel)
                dataLabels.append(valueLabel)
                dataLabels.append(unitLabel)
            } else {
                let alignment: NSTextAlignment = (label == "Util" || label == "Swap Ins" || label == "Swap Outs" || label == "Efficiency") ? .right : .left
                let frameWidth = VerticalTableLayout.valueWidth
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: VerticalTableLayout.valueX(),
                        y: rowY,
                        width: frameWidth,
                        height: VerticalTableLayout.rowHeight
                    ),
                    alignment: alignment,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                dataLabels.append(valueLabel)
            }
        }
    }
    
    override func updateData(with stats: MemoryStats) {
        guard dataLabels.count >= 10 else { return }
        
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
        
        dataLabels[7].stringValue = String(stats.swapIns)
        dataLabels[8].stringValue = String(stats.swapOuts)
        
        // Calculate swap efficiency (lower is better - ratio of ins to outs)
        let efficiency = (stats.swapOuts > 0) ? Double(stats.swapIns) / Double(stats.swapOuts) : 0.0
        dataLabels[9].stringValue = String(format: "%.2f", efficiency)
    }
    
    
}

class ProcessTableSection: BaseTableSection {
    private var processHeaderLabels: [ProcessSortColumn: NSTextField] = [:]
    private var currentSortColumn: ProcessSortColumn = .memoryPercent
    private var sortDescending: Bool = true
    
    init(yPosition: CGFloat) {
        super.init(title: "Top Processes", height: VerticalTableLayout.processTableHeight, yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth: CGFloat = 750
        let xPosition: CGFloat = (containerView.bounds.width - sectionWidth) / 2
        
        let section = NSView(frame: NSRect(x: xPosition, y: yPosition, width: sectionWidth, height: height))
        section.wantsLayer = true
        containerView.addSubview(section)
        self.sectionView = section
        
        delegate.addTableBackground(to: section, padding: 3)
        createSectionTitle()
        createHeaders()
        createDataFields()
    }
    
    override func getTitleFontSize() -> CGFloat {
        return 22
    }
    
    override func getTitleXPosition() -> CGFloat {
        return (750 - 200) / 2  // Center the 200px title within the 750px section
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
                alignment: .center
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

protocol StatsWindowDelegate: AnyObject {
    func windowWasClosed()
}

class StatsWindowController: NSWindowController, SortHandler, TableSectionDelegate {
    
    weak var delegate: StatsWindowDelegate?
    
    private var statsView: NSView!
    private var timer: Timer?
    private var appearanceObserver: NSObjectProtocol?
    
    private var tableSections: [BaseTableSection] = []
    private var dataService: StatsDataService!
    private var uiFactory: UIComponentFactory!
    private var themeManager: StatsThemeManager!
    
    private var pinButton: NSButton!
    private var isPinned: Bool = false
    
    override init(window: NSWindow?) {
        super.init(window: window)
        setupServices()
        setupWindow()
        setupAppearanceObserver()
    }
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 794, height: TableLayoutManager.shared.calculateWindowHeight()),
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
    
    
    
    
    private func setupServices() {
        dataService = StatsDataService()
        uiFactory = UIComponentFactory(currentSortColumn: dataService.getCurrentSortColumn(), sortDescending: dataService.isSortDescending())
        themeManager = StatsThemeManager.shared
        dataService.sortHandler = self
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
        setupPinButton()
    }
    
    private func createTableSections() {
        let windowHeight = statsView.bounds.height
        tableSections = TableLayoutManager.shared.createTableSections(windowHeight: windowHeight)
    }
    
    private func setupTableSections() {
        for section in tableSections {
            section.setupSection(in: statsView, delegate: self)
        }
    }
    
    private func setupPinButton() {
        pinButton = NSButton(frame: NSRect(x: statsView.bounds.width - 25, y: statsView.bounds.height - 25, width: 25, height: 25))
        pinButton.bezelStyle = .shadowlessSquare
        pinButton.isBordered = false
        pinButton.wantsLayer = true
        
        pinButton.target = self
        pinButton.action = #selector(togglePinState)
        
        updatePinButtonAppearance()
        
        statsView.addSubview(pinButton, positioned: .above, relativeTo: nil)
    }
    
    @objc private func togglePinState() {
        guard let window = window else { return }
        
        if isPinned {
            isPinned = false
            
            window.level = .floating
            window.styleMask = [.borderless]
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            
            updatePinButtonAppearance()
            hideWindow()
            delegate?.windowWasClosed()
        } else {
            isPinned = true
            
            window.level = .normal
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.title = "MemStat"
            window.titlebarAppearsTransparent = false
            window.titleVisibility = .visible
            
            updatePinButtonAppearance()
        }
    }
    
    private func updatePinButtonAppearance() {
        pinButton.image = nil
        let appearance = themeManager.getCurrentAppearance(for: window)
        pinButton.image = isPinned ? FormatUtilities.createCloseIcon(appearance: appearance) : FormatUtilities.createPinIcon(appearance: appearance)
        pinButton.needsDisplay = true
    }
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField {
        return uiFactory.createHeaderLabel(text, frame: frame, isDarkBackground: isDarkBackground, sortColumn: sortColumn, fontSize: fontSize, alignment: alignment)
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        return uiFactory.createDataLabel(text: text, frame: frame, alignment: alignment, useMonospacedFont: useMonospacedFont)
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        uiFactory.addTableBackground(to: section, padding: padding)
    }
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        dataService.updateSortingAndRefresh(sortColumn: sortColumn, sortDescending: sortDescending)
        uiFactory = UIComponentFactory(currentSortColumn: sortColumn, sortDescending: sortDescending)
        updateStats()
    }
    
    private func setupAppearanceObserver() {
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateColors()
        }
        
        window?.contentView?.addObserver(self, forKeyPath: "effectiveAppearance", options: [.new], context: nil)
    }
    
    private func updateColors() {
        themeManager.applyTheme(to: statsView)
        updatePinButtonAppearance()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "effectiveAppearance" {
            updateColors()
        }
    }
    
    deinit {
        if let observer = appearanceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        window?.contentView?.removeObserver(self, forKeyPath: "effectiveAppearance")
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
        
        if isPinned {
            isPinned = false
            updatePinButtonAppearance()
            
            if let window = window {
                window.level = .floating
                window.styleMask = [.borderless]
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
            }
        }
    }
    
    func isPinnedWindow() -> Bool {
        return isPinned
    }
    
    func handlePinButtonClick() {
        if isPinned {
            isPinned = false
            updatePinButtonAppearance()
            hideWindow()
        }
    }
    
    private func updateStats() {
        let stats = dataService.getCurrentStats()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for section in self.tableSections {
                section.updateData(with: stats)
            }
        }
    }
}