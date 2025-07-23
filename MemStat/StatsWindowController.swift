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

protocol StatsWindowDelegate: AnyObject {
    func windowWasClosed()
}

class StatsWindowController: NSWindowController, NSWindowDelegate, SortHandler, TableSectionDelegate {
    
    weak var delegate: StatsWindowDelegate?
    
    private var statsView: NSView!
    private var timer: Timer?
    private var appearanceObserver: NSObjectProtocol?
    
    private var tableSections: [BaseTableSection] = []
    private var dataService: StatsDataService!
    private var uiFactory: UIComponentFactory!
    private var themeManager: StatsThemeManager!
    
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
        
        window.delegate = self
        window.level = .normal
        window.backgroundColor = NSColor.controlBackgroundColor
        window.hasShadow = true
        window.isOpaque = false
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 0
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
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment, isSortColumn: Bool) -> NSTextField {
        let isCurrentSortColumn = sortColumn != nil && sortColumn == dataService.getCurrentSortColumn()
        return uiFactory.createHeaderLabel(text, frame: frame, isDarkBackground: isDarkBackground, sortColumn: sortColumn, fontSize: fontSize, alignment: alignment, isSortColumn: isCurrentSortColumn)
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        return uiFactory.createDataLabel(text: text, frame: frame, alignment: alignment, useMonospacedFont: useMonospacedFont)
    }
    
    func createProcessDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        return uiFactory.createProcessDataLabel(text: text, frame: frame, alignment: alignment, useMonospacedFont: useMonospacedFont)
    }
    
    func createRowLabel(text: String, frame: NSRect, alignment: NSTextAlignment) -> NSTextField {
        return uiFactory.createRowLabel(text: text, frame: frame, alignment: alignment)
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        uiFactory.addTableBackground(to: section, padding: padding)
    }
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        dataService.updateSortingAndRefresh(sortColumn: sortColumn, sortDescending: sortDescending)
        uiFactory = UIComponentFactory(currentSortColumn: sortColumn, sortDescending: sortDescending)
        updateStats()
    }
    
    func getCurrentSortColumn() -> ProcessSortColumn {
        return dataService.getCurrentSortColumn()
    }
    
    func isSortDescending() -> Bool {
        return dataService.isSortDescending()
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
        let currentSortColumn = dataService.getCurrentSortColumn()
        themeManager.applyTheme(to: statsView, currentSortColumn: currentSortColumn)
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
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        delegate?.windowWasClosed()
        return false
    }
    
    func isPinnedWindow() -> Bool {
        return false
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
    
    func startUpdatingStats() {
        updateStats()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
}