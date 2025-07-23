import Cocoa

enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light = "light"  
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        }
    }
}

class AppearanceManager {
    static let shared = AppearanceManager()
    
    private let userDefaultsKey = "AppearanceMode"
    
    private init() {}
    
    var currentMode: AppearanceMode {
        get {
            let savedValue = UserDefaults.standard.string(forKey: userDefaultsKey) ?? AppearanceMode.system.rawValue
            return AppearanceMode(rawValue: savedValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
        }
    }
    
    func setAppearance(_ mode: AppearanceMode) {
        currentMode = mode
        NSApp.appearance = mode.nsAppearance
    }
    
    func createAppearanceMenu(target: AnyObject, updateHandler: Selector) -> NSMenuItem {
        let appearanceItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        let appearanceSubmenu = NSMenu()
        
        for mode in AppearanceMode.allCases {
            let modeItem = NSMenuItem(title: mode.displayName, action: #selector(AppearanceMenuHandler.appearanceChanged(_:)), keyEquivalent: "")
            modeItem.target = AppearanceMenuHandler.shared
            modeItem.representedObject = mode
            modeItem.state = (mode == currentMode) ? .on : .off
            appearanceSubmenu.addItem(modeItem)
        }
        
        appearanceItem.submenu = appearanceSubmenu
        AppearanceMenuHandler.shared.updateHandler = updateHandler
        AppearanceMenuHandler.shared.target = target
        
        return appearanceItem
    }
    
    func restoreAppearanceMode() {
        setAppearance(currentMode)
    }
    
    func updateAppearanceMenu(_ menu: NSMenu) {
        guard let appearanceItem = menu.items.first(where: { $0.title == "Appearance" }),
              let submenu = appearanceItem.submenu else { return }
        
        for item in submenu.items {
            if let mode = item.representedObject as? AppearanceMode {
                item.state = (mode == currentMode) ? .on : .off
            }
        }
    }
}

@objc private class AppearanceMenuHandler: NSObject {
    static let shared = AppearanceMenuHandler()
    
    var updateHandler: Selector?
    weak var target: AnyObject?
    
    @objc func appearanceChanged(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? AppearanceMode else { return }
        
        AppearanceManager.shared.setAppearance(mode)
        
        if let target = target, let handler = updateHandler {
            _ = target.perform(handler)
        }
    }
}