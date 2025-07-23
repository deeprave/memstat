import Cocoa
import Foundation

fileprivate func formatBytes(_ bytes: UInt64) -> String {
    let units = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    var value = Double(bytes)
    var unitIndex = 0
    
    while value > 1024 && unitIndex < units.count - 1 {
        value /= 1024
        unitIndex += 1
    }
    
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = unitIndex > 0 ? 2 : 0
    formatter.minimumFractionDigits = 0
    
    if let formattedValue = formatter.string(from: NSNumber(value: value)) {
        return "\(formattedValue) \(units[unitIndex])"
    }
    
    return "\(value) \(units[unitIndex])"
}

fileprivate func separateValueAndUnit(_ text: String) -> (value: String, unit: String) {
    let components = text.components(separatedBy: " ")
    if components.count >= 2 {
        return (components[0], components[1])
    }
    return (text, "")
}

fileprivate func createSortableHeaderText(_ text: String, sortColumn: ProcessSortColumn?, currentSortColumn: ProcessSortColumn?, sortDescending: Bool) -> String {
    guard let sortColumn = sortColumn,
          let currentSort = currentSortColumn,
          sortColumn == currentSort else {
        return text
    }
    
    let arrow = sortDescending ? "▼" : "▲"
    return "\(text) \(arrow)"
}


class MemoryTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Memory", height: TableLayoutManager.VerticalTableLayout.calculateTableHeight(for: 7), yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth = TableLayoutManager.VerticalTableLayout.memoryTableWidth
        let xPosition = TableLayoutManager.VerticalTableLayout.memoryTableX(containerWidth: containerView.bounds.width)
        
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
        return TableLayoutManager.VerticalTableLayout.sectionTitleY(sectionHeight: height)
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
            { formatBytes(stats.totalMemory) },
            { formatBytes(stats.usedMemory) },
            { formatBytes(stats.appPhysicalMemory) },
            { formatBytes(systemMemory) },
            { formatBytes(cacheMemory) },
            { formatBytes(stats.freeMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = separateValueAndUnit(formatted)
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
        super.init(title: "Virtual", height: TableLayoutManager.VerticalTableLayout.calculateTableHeight(for: 7), yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth = TableLayoutManager.VerticalTableLayout.virtualTableWidth
        let xPosition = TableLayoutManager.VerticalTableLayout.virtualTableX(containerWidth: containerView.bounds.width)
        
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
        return TableLayoutManager.VerticalTableLayout.sectionTitleY(sectionHeight: height)
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
        
        let customLabelWidth: CGFloat = 105
        
        for (index, (label, hasUnits)) in metrics.enumerated() {
            let rowY = TableLayoutManager.VerticalTableLayout.rowY(rowIndex: index, sectionHeight: height)
            
            let labelView = delegate.createRowLabel(
                text: label,
                frame: NSRect(
                    x: TableLayoutManager.VerticalTableLayout.labelX(),
                    y: rowY,
                    width: customLabelWidth,
                    height: TableLayoutManager.VerticalTableLayout.rowHeight
                ),
                alignment: .right
            )
            section.addSubview(labelView)
            
            if hasUnits {
                let customValueX = customLabelWidth + TableLayoutManager.VerticalTableLayout.labelValueSpacing
                
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: customValueX,
                        y: rowY,
                        width: TableLayoutManager.VerticalTableLayout.valueWidth - TableLayoutManager.VerticalTableLayout.unitWidth - 5 + 5,
                        height: TableLayoutManager.VerticalTableLayout.rowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                let customUnitX = customValueX + (TableLayoutManager.VerticalTableLayout.valueWidth - TableLayoutManager.VerticalTableLayout.unitWidth - 5 + 5)
                
                let unitLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(
                        x: customUnitX,
                        y: rowY,
                        width: 26,
                        height: TableLayoutManager.VerticalTableLayout.rowHeight
                    ),
                    alignment: .right,
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
            { formatBytes(stats.activeMemory) },
            { formatBytes(stats.inactiveMemory) },
            { formatBytes(stats.wiredMemory) },
            { formatBytes(stats.compressedMemory) },
            { formatBytes(stats.appVirtualMemory) },
            { formatBytes(stats.anonymousMemory) },
            { formatBytes(stats.fileBackedMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = separateValueAndUnit(formatted)
            let labelIndex = index * 2
            
            dataLabels[labelIndex].stringValue = parts.value
            dataLabels[labelIndex + 1].stringValue = parts.unit
        }
    }
}

class SwapTableSection: BaseTableSection {
    
    init(yPosition: CGFloat) {
        super.init(title: "Swap", height: TableLayoutManager.VerticalTableLayout.calculateTableHeight(for: 7), yPosition: yPosition)
    }
    
    override func setupSection(in containerView: NSView, delegate: TableSectionDelegate) {
        self.containerView = containerView
        self.delegate = delegate
        
        let sectionWidth = TableLayoutManager.VerticalTableLayout.swapTableWidth
        let xPosition = TableLayoutManager.VerticalTableLayout.swapTableX(containerWidth: containerView.bounds.width)
        
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
        return TableLayoutManager.VerticalTableLayout.sectionTitleY(sectionHeight: height)
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
            let rowY = TableLayoutManager.VerticalTableLayout.rowY(rowIndex: index, sectionHeight: height)
            
            let labelView = delegate.createRowLabel(
                text: label,
                frame: NSRect(
                    x: TableLayoutManager.VerticalTableLayout.labelX(),
                    y: rowY,
                    width: TableLayoutManager.VerticalTableLayout.labelWidth,
                    height: TableLayoutManager.VerticalTableLayout.rowHeight
                ),
                alignment: .right
            )
            section.addSubview(labelView)
            
            if hasUnits {
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: TableLayoutManager.VerticalTableLayout.valueX(),
                        y: rowY,
                        width: TableLayoutManager.VerticalTableLayout.valueWidth - TableLayoutManager.VerticalTableLayout.unitWidth - 5,
                        height: TableLayoutManager.VerticalTableLayout.rowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                let unitLabel = delegate.createDataLabel(
                    text: "",
                    frame: NSRect(
                        x: TableLayoutManager.VerticalTableLayout.unitX(),
                        y: rowY,
                        width: 26,
                        height: TableLayoutManager.VerticalTableLayout.rowHeight
                    ),
                    alignment: .right,
                    useMonospacedFont: false
                )
                
                section.addSubview(valueLabel)
                section.addSubview(unitLabel)
                dataLabels.append(valueLabel)
                dataLabels.append(unitLabel)
            } else {
                let unitFieldRightEdge = TableLayoutManager.VerticalTableLayout.unitX() + 26
                let fieldWidth = TableLayoutManager.VerticalTableLayout.valueWidth
                let fieldX = unitFieldRightEdge - fieldWidth
                
                let valueLabel = delegate.createDataLabel(
                    text: "Loading...",
                    frame: NSRect(
                        x: fieldX,
                        y: rowY,
                        width: fieldWidth,
                        height: TableLayoutManager.VerticalTableLayout.rowHeight
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
        guard dataLabels.count >= 10 else { return }
        
        let formatters = [
            { formatBytes(stats.swapTotalMemory) },
            { formatBytes(stats.swapUsedMemory) },
            { formatBytes(stats.swapFreeMemory) }
        ]
        
        for (index, formatter) in formatters.enumerated() {
            let formatted = formatter()
            let parts = separateValueAndUnit(formatted)
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
            dataLabels[6].textColor = ColorTheme.alwaysDarkText
        }
        
        dataLabels[7].stringValue = String(stats.swapIns)
        dataLabels[8].stringValue = String(stats.swapOuts)
        
        let efficiency = (stats.swapOuts > 0) ? Double(stats.swapIns) / Double(stats.swapOuts) : 0.0
        dataLabels[9].stringValue = String(format: "%.2f", efficiency)
    }
}

class ProcessTableSection: BaseTableSection {
    private var processHeaderLabels: [ProcessSortColumn: NSTextField] = [:]
    
    init(yPosition: CGFloat) {
        super.init(title: "Top Processes", height: TableLayoutManager.VerticalTableLayout.processTableHeight, yPosition: yPosition)
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
        return TableLayoutManager.ProcessTableLayout.sectionTitleY(tableHeight: height)
    }
    
    
    override func createHeaders() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        let columns = TableLayoutManager.ProcessTableLayout.columns
        for (index, column) in columns.enumerated() {
            let x = TableLayoutManager.ProcessTableLayout.xPosition(for: index)
            let headerWidth = (index == columns.count - 1) ? column.width : column.width + 10
            let frame = NSRect(x: x, y: TableLayoutManager.ProcessTableLayout.headerY(tableHeight: height), width: headerWidth, height: 26)
            
            let headerLabel = delegate.createHeaderLabel(
                column.title,
                frame: frame,
                isDarkBackground: true,
                sortColumn: column.sortColumn,
                fontSize: 12,
                alignment: .center,
                isSortColumn: false
            )
            
            processHeaderLabels[column.sortColumn] = headerLabel
            
            let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleHeaderClick))
            headerLabel.addGestureRecognizer(clickGesture)
            
            section.addSubview(headerLabel)
        }
        
        createBorders()
    }
    
    private func createBorders() {
        guard let section = sectionView else { return }
        
        let borderTopMargin: CGFloat = 5
        let borderHeight = TableLayoutManager.ProcessTableLayout.headerY(tableHeight: height) - borderTopMargin
        
        for i in 1..<TableLayoutManager.ProcessTableLayout.columns.count {
            let x = TableLayoutManager.ProcessTableLayout.xPosition(for: i)
            let border = NSView(frame: NSRect(x: x, y: borderTopMargin, width: 1, height: borderHeight))
            border.wantsLayer = true
            border.layer?.backgroundColor = ColorTheme.borderColor.cgColor
            section.addSubview(border)
        }
        
        let bottomBorder = NSView(frame: NSRect(x: 0, y: 0, width: section.bounds.width, height: 1))
        bottomBorder.wantsLayer = true
        bottomBorder.layer?.backgroundColor = ColorTheme.borderColor.cgColor
        section.addSubview(bottomBorder)
    }
    
    override func createDataFields() {
        guard let section = sectionView, let delegate = delegate else { return }
        
        for i in 0..<20 {
            let yPos = TableLayoutManager.ProcessTableLayout.dataStartY(tableHeight: height) - (CGFloat(i) * TableLayoutManager.ProcessTableLayout.dataRowHeight)
            
            for (columnIndex, column) in TableLayoutManager.ProcessTableLayout.columns.enumerated() {
                let x = TableLayoutManager.ProcessTableLayout.xPosition(for: columnIndex)
                let dataWidth = column.width - CGFloat(10)
                let dataX = x + CGFloat(5)
                
                let valueLabel = delegate.createProcessDataLabel(
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
        guard let headerLabel = sender.view as? NSTextField,
              let delegate = delegate else { return }
        
        var clickedColumn: ProcessSortColumn?
        
        for (sortColumn, label) in processHeaderLabels {
            if label === headerLabel {
                clickedColumn = sortColumn
                break
            }
        }
        
        guard let column = clickedColumn else { return }
        
        let currentSortColumn = delegate.getCurrentSortColumn()
        let sortDescending = delegate.isSortDescending()
        
        let newSortDescending: Bool
        if column == currentSortColumn {
            newSortDescending = !sortDescending
        } else {
            newSortDescending = (column != .command)
        }
        
        delegate.updateSortingAndRefresh(sortColumn: column, sortDescending: newSortDescending)
        updateAllProcessHeaders()
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
        guard let label = processHeaderLabels[sortColumn],
              let delegate = delegate else { return }
        
        let currentSortColumn = delegate.getCurrentSortColumn()
        let sortDescending = delegate.isSortDescending()
        let isActiveSort = sortColumn == currentSortColumn
        
        let displayText = createSortableHeaderText(title, sortColumn: sortColumn, currentSortColumn: currentSortColumn, sortDescending: sortDescending)
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