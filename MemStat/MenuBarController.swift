import Cocoa

class MenuBarController: NSObject, StatsWindowDelegate, AppearanceMenuUpdateDelegate {
    
    var statusItem: NSStatusItem!
    private var statsWindowController: StatsWindowController!
    private var isWindowVisible = false
    private var contextMenu: NSMenu!
    
    override init() {
        super.init()
        
        restoreAppearanceMode()
        setupMenuBar()
        setupStatsWindow()
        updateLoginItemMenu()
        updateAppearanceMenu()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: 28)
        
        if let button = statusItem.button {
            let image = createMenuBarIcon()
            button.image = image
            button.title = ""
            
            button.action = #selector(toggleWindow)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupContextMenu()
        statusItem.menu = nil
    }
    
    private func setupContextMenu() {
        let menu = NSMenu()
        
        let aboutItem = NSMenuItem(title: "About MemStat", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let appearanceItem = AppearanceManager.shared.createAppearanceMenu(delegate: self)
        menu.addItem(appearanceItem)
        
        AppearanceManager.shared.registerMenuForUpdates(menu, delegate: self)
        
        menu.addItem(NSMenuItem.separator())
        
        let loginItem = NSMenuItem(title: "Open at Login", action: #selector(toggleLoginItem), keyEquivalent: "")
        loginItem.target = self
        menu.addItem(loginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let switchModeItem = NSMenuItem(title: "Switch to Regular Window", action: #selector(switchToWindowMode), keyEquivalent: "")
        switchModeItem.target = self
        menu.addItem(switchModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit MemStat", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        contextMenu = menu
    }
    
    private func setupStatsWindow() {
        statsWindowController = StatsWindowController()
        statsWindowController.delegate = self
        
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            if self?.isWindowVisible == true && !(self?.statsWindowController.isPinnedWindow() ?? false) {
                self?.hideWindow()
            }
        }
    }
    
    @objc private func toggleWindow() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            if let button = statusItem.button {
                contextMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
            }
            return
        }
        if isWindowVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    private func showWindow() {
        guard let button = statusItem.button else { return }
        
        let buttonRect = button.window?.convertToScreen(button.bounds) ?? NSRect.zero
        let windowOrigin = NSPoint(x: buttonRect.midX - 350, y: buttonRect.minY - 756)
        
        statsWindowController.showWindow(at: windowOrigin)
        isWindowVisible = true
    }
    
    private func hideWindow() {
        statsWindowController.hideWindow()
        isWindowVisible = false
    }
    
    func windowWasClosed() {
        isWindowVisible = false
    }
    
    @objc private func showAbout() {
        if isRunningTests() {
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "MemStat"
        alert.informativeText = "Version\n\(AppVersion.displayVersion)\nDavid Nugent\nBuild: \(AppVersion.buildNumber)\nCompiled: \(getCompilationDate())\n\nA simple memory statistics monitor for macOS.\n\nCurrent Mode: Menu Bar"
        alert.addButton(withTitle: "OK")
        
        alert.icon = createAboutIcon()
        
        alert.runModal()
    }
    
    @objc private func toggleLoginItem() {
        let loginItems = LoginItemsManager.shared
        let isEnabled = loginItems.isEnabled()
        
        if isEnabled {
            loginItems.disable()
        } else {
            loginItems.enable()
        }
        
        updateLoginItemMenu()
    }
    
    @objc private func switchToWindowMode() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.switchToMode(.window)
        }
    }
    
    @objc private func quitApp() {
        if isRunningTests() {
            return
        }
        NSApplication.shared.terminate(nil)
    }
    
    private func isRunningTests() -> Bool {
        return NSClassFromString("XCTestCase") != nil
    }
    
    
    private func updateLoginItemMenu() {
        for item in contextMenu.items {
            if item.title == "Open at Login" {
                item.state = LoginItemsManager.shared.isEnabled() ? .on : .off
                break
            }
        }
    }
    
    func updateAppearanceMenu() {
        AppearanceManager.shared.updateAppearanceMenu(contextMenu)
    }
    
    private func restoreAppearanceMode() {
        AppearanceManager.shared.restoreAppearanceMode()
    }
    
    private func getCompilationDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    private func createMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let chipRect = NSRect(x: 4, y: 2, width: 10, height: 14)
        NSColor.black.setFill()
        NSBezierPath(roundedRect: chipRect, xRadius: 1, yRadius: 1).fill()
        
        for i in 0..<6 {
            let pinRect = NSRect(x: 2, y: 4 + i * 2, width: 2, height: 1)
            NSBezierPath(rect: pinRect).fill()
        }
        
        for i in 0..<6 {
            let pinRect = NSRect(x: 14, y: 4 + i * 2, width: 2, height: 1)
            NSBezierPath(rect: pinRect).fill()
        }
        
        let notchRect = NSRect(x: 7, y: 2, width: 4, height: 1)
        NSColor.white.setFill()
        NSBezierPath(roundedRect: notchRect, xRadius: 0.5, yRadius: 0.5).fill()
        
        image.unlockFocus()
        image.isTemplate = true
        
        return image
    }
    
    private func createAboutIcon() -> NSImage {
        let size = NSSize(width: 64, height: 64)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let circleRect = NSRect(x: 4, y: 4, width: 56, height: 56)
        let circlePath = NSBezierPath(ovalIn: circleRect)
        
        NSColor(red: 0.56, green: 0.76, blue: 0.91, alpha: 1.0).setFill()
        circlePath.fill()
        
        let highlightRect = NSRect(x: 12, y: 10, width: 40, height: 40)
        let highlightPath = NSBezierPath(ovalIn: highlightRect)
        NSColor(red: 0.62, green: 0.80, blue: 0.93, alpha: 0.6).setFill()
        highlightPath.fill()
        
        NSColor(red: 0.29, green: 0.56, blue: 0.76, alpha: 1.0).setStroke()
        circlePath.lineWidth = 2
        circlePath.stroke()
        
        let chipRect = NSRect(x: 22, y: 8, width: 21, height: 48)
        NSColor(red: 0.29, green: 0.48, blue: 0.65, alpha: 1.0).setFill()
        
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowOffset = NSSize(width: 1, height: -2)
        shadow.shadowBlurRadius = 2
        shadow.set()
        
        NSBezierPath(roundedRect: chipRect, xRadius: 2, yRadius: 2).fill()
        
        shadow.shadowColor = nil
        shadow.set()
        
        NSColor(red: 0.12, green: 0.23, blue: 0.37, alpha: 1.0).setFill()
        
        for i in 0..<10 {
            let pinRect = NSRect(x: 16, y: 10 + i * 4, width: 6, height: 2)
            NSBezierPath(rect: pinRect).fill()
        }
        
        for i in 0..<10 {
            let pinRect = NSRect(x: 43, y: 10 + i * 4, width: 6, height: 2)
            NSBezierPath(rect: pinRect).fill()
        }
        
        let notchRect = NSRect(x: 28, y: 8, width: 9, height: 2)
        NSColor(red: 0.12, green: 0.23, blue: 0.37, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: notchRect, xRadius: 1, yRadius: 1).fill()
        
        let labelRect = NSRect(x: 26, y: 28, width: 12, height: 8)
        NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9).setFill()
        NSBezierPath(roundedRect: labelRect, xRadius: 1, yRadius: 1).fill()
        
        image.unlockFocus()
        
        return image
    }
    
    deinit {
        AppearanceManager.shared.unregisterAllMenusForDelegate(self)
    }
}