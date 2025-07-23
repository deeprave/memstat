import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindowController: MainWindowController?
    var menuBarController: MenuBarController?
    private var currentMode: AppMode = .window
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let commandLineMode = parseCommandLineMode()
        
        if let forcedMode = commandLineMode {
            currentMode = forcedMode
        } else {
            let savedMode = UserDefaults.standard.string(forKey: "AppMode") ?? AppMode.window.rawValue
            currentMode = AppMode(rawValue: savedMode) ?? .window
        }
        
        startInMode(currentMode)
        restoreAppearanceMode()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Only terminate when last window closes in window mode
        return currentMode == .window
    }
    
    // MARK: - Command Line Parsing
    
    private func parseCommandLineMode() -> AppMode? {
        let arguments = CommandLine.arguments
        
        // Check for --menubar or -m flag
        if arguments.contains("--menubar") || arguments.contains("-m") {
            return .menubar
        }
        
        // Check for --window or -w flag
        if arguments.contains("--window") || arguments.contains("-w") {
            return .window
        }
        
        // Check for --help or -h flag
        if arguments.contains("--help") || arguments.contains("-h") {
            printUsage()
            NSApp.terminate(nil)
            return nil
        }
        
        return nil
    }
    
    private func printUsage() {
        print("""
        MemStat - macOS Memory Statistics Monitor
        
        Usage: MemStat [OPTIONS]
        
        Options:
          -m, --menubar     Force startup in menu bar mode
          -w, --window      Force startup in regular window mode
          -h, --help        Show this help message
        
        If no mode is specified, the app will use the last saved preference.
        Default mode is regular window mode if no preference is saved.
        Command line flags override saved preferences for this session only.
        
        Examples:
          MemStat --menubar     # Start in menu bar mode
          MemStat -w            # Start in window mode
        """)
    }
    
    // MARK: - Mode Management
    
    private func startInMode(_ mode: AppMode) {
        currentMode = mode
        
        switch mode {
        case .menubar:
            startMenuBarMode()
        case .window:
            startWindowMode()
        }
    }
    
    private func startMenuBarMode() {
        // Clean up window mode if active
        mainWindowController?.close()
        mainWindowController = nil
        
        // Start menubar mode
        menuBarController = MenuBarController()
        
        // Hide dock icon in menubar mode
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func startWindowMode() {
        // Clean up menubar mode if active
        menuBarController = nil
        
        // Start window mode
        setupApplicationMenu()
        mainWindowController = MainWindowController()
        mainWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // Show dock icon in window mode
        NSApp.setActivationPolicy(.regular)
    }
    
    func switchToMode(_ mode: AppMode) {
        guard mode != currentMode else { return }
        
        // Save preference
        UserDefaults.standard.set(mode.rawValue, forKey: "AppMode")
        
        // Show restart dialog
        let alert = NSAlert()
        alert.messageText = "Mode Change"
        alert.informativeText = "MemStat will restart to switch to \(mode.displayName) mode."
        alert.addButton(withTitle: "Restart Now")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            restartApplication()
        } else {
            // Revert the preference if cancelled
            UserDefaults.standard.set(currentMode.rawValue, forKey: "AppMode")
        }
    }
    
    private func restartApplication() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        
        NSApp.terminate(nil)
    }
    
    private func setupApplicationMenu() {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        
        let aboutItem = NSMenuItem(title: "About MemStat", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        appMenu.addItem(aboutItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        let appearanceItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        let appearanceSubmenu = NSMenu()
        
        let autoItem = NSMenuItem(title: "Auto", action: #selector(setAppearanceAuto), keyEquivalent: "")
        autoItem.target = self
        appearanceSubmenu.addItem(autoItem)
        
        let lightItem = NSMenuItem(title: "Light", action: #selector(setAppearanceLight), keyEquivalent: "")
        lightItem.target = self
        appearanceSubmenu.addItem(lightItem)
        
        let darkItem = NSMenuItem(title: "Dark", action: #selector(setAppearanceDark), keyEquivalent: "")
        darkItem.target = self
        appearanceSubmenu.addItem(darkItem)
        
        appearanceItem.submenu = appearanceSubmenu
        appMenu.addItem(appearanceItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        // Add mode selection menu
        let modeItem = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        let modeSubmenu = NSMenu()
        
        for mode in AppMode.allCases {
            let item = NSMenuItem(title: mode.displayName, action: #selector(switchMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode
            item.state = mode == currentMode ? .on : .off
            modeSubmenu.addItem(item)
        }
        
        modeItem.submenu = modeSubmenu
        appMenu.addItem(modeItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit MemStat", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitItem)
        
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        NSApp.mainMenu = mainMenu
        updateAppearanceMenu()
    }
    
    @objc private func switchMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? AppMode else { return }
        switchToMode(mode)
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MemStat"
        alert.informativeText = "Version\n\(AppVersion.displayVersion)\nDavid Nugent\nBuild: \(AppVersion.buildNumber)\nCompiled: \(getCompilationDate())\n\nA simple memory statistics monitor for macOS.\n\nCurrent Mode: \(currentMode.displayName)"
        alert.addButton(withTitle: "OK")
        alert.icon = createAboutIcon()
        alert.runModal()
    }
    
    @objc private func setAppearanceAuto() {
        NSApp.appearance = nil
        UserDefaults.standard.set("auto", forKey: "AppearanceMode")
        updateAppearanceMenu()
    }
    
    @objc private func setAppearanceLight() {
        NSApp.appearance = NSAppearance(named: .aqua)
        UserDefaults.standard.set("light", forKey: "AppearanceMode")
        updateAppearanceMenu()
    }
    
    @objc private func setAppearanceDark() {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        UserDefaults.standard.set("dark", forKey: "AppearanceMode")
        updateAppearanceMenu()
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
    
    private func updateAppearanceMenu() {
        guard let mainMenu = NSApp.mainMenu else { return }
        let currentMode = UserDefaults.standard.string(forKey: "AppearanceMode") ?? "auto"
        
        for item in mainMenu.items {
            if let submenu = item.submenu {
                for menuItem in submenu.items {
                    if menuItem.title == "Appearance", let appearanceSubmenu = menuItem.submenu {
                        for appearanceItem in appearanceSubmenu.items {
                            switch appearanceItem.title {
                            case "Auto":
                                appearanceItem.state = currentMode == "auto" ? .on : .off
                            case "Light":
                                appearanceItem.state = currentMode == "light" ? .on : .off
                            case "Dark":
                                appearanceItem.state = currentMode == "dark" ? .on : .off
                            default:
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    private func getCompilationDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
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
}
