import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    private var statsWindowController: StatsWindowController!
    
    override init(window: NSWindow?) {
        super.init(window: window)
        setupWindow()
        setupStatsView()
        restoreAppearanceMode()
    }
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 794, height: TableLayoutManager.shared.calculateWindowHeight()),
            styleMask: [.titled, .closable, .miniaturizable],
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
        window.title = "MemStat"
        window.center()
        window.backgroundColor = NSColor.controlBackgroundColor
        window.hasShadow = true
        window.isOpaque = false
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        
        window.styleMask.remove(.resizable)
        
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 0
    }
    
    private func setupStatsView() {
        guard let window = window else { return }
        
        statsWindowController = StatsWindowController()
        
        if let statsView = statsWindowController.window?.contentView {
            statsView.removeFromSuperview()
            statsView.frame = window.contentView!.bounds
            statsView.autoresizingMask = [.width, .height]
            window.contentView?.addSubview(statsView)
        }
        
        statsWindowController.startUpdatingStats()
    }
    
    private func restoreAppearanceMode() {
        let savedMode = UserDefaults.standard.string(forKey: "AppearanceMode") ?? "auto"
        
        switch savedMode {
        case "light":
            NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":
            NSApp.appearance = NSAppearance(named: .darkAqua)
        default:
            NSApp.appearance = nil
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        statsWindowController?.hideWindow()
        NSApp.terminate(nil)
    }
}