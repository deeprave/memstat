import Cocoa

enum MenuTag: Int {
    case appearanceMenu = 1000
}

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
    private var registeredMenus: [(menu: NSMenu, updateHandler: () -> Void)] = []
    
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
        updateAllAppearanceMenus()
    }
    
    func createAppearanceMenu(target: AnyObject, updateHandler: Selector) -> NSMenuItem {
        let appearanceItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        appearanceItem.tag = MenuTag.appearanceMenu.rawValue
        let appearanceSubmenu = NSMenu()
        let menuHandler = AppearanceMenuHandler(target: target, updateHandler: updateHandler)
        
        for mode in AppearanceMode.allCases {
            let modeItem = NSMenuItem(title: mode.displayName, action: #selector(AppearanceMenuHandler.appearanceChanged(_:)), keyEquivalent: "")
            modeItem.target = menuHandler
            modeItem.representedObject = AppearanceMenuData(mode: mode, handler: menuHandler)
            modeItem.state = (mode == currentMode) ? .on : .off
            appearanceSubmenu.addItem(modeItem)
        }
        
        appearanceItem.submenu = appearanceSubmenu
        
        return appearanceItem
    }
    
    func registerMenuForUpdates(_ menu: NSMenu, target: AnyObject, updateHandler: Selector) {
        let updateClosure = { [weak target] in
            if let target = target {
                _ = target.perform(updateHandler)
            }
        }
        registeredMenus.append((menu: menu, updateHandler: updateClosure))
    }
    
    private func updateAllAppearanceMenus() {
        // Clean up any menus that have been deallocated
        registeredMenus = registeredMenus.filter { $0.menu.supermenu != nil || $0.menu.numberOfItems > 0 }
        
        // Update all registered menus
        for (_, updateHandler) in registeredMenus {
            updateHandler()
        }
    }
    
    func restoreAppearanceMode() {
        setAppearance(currentMode)
    }
    
    func updateAppearanceMenu(_ menu: NSMenu) {
        guard let appearanceItem = menu.items.first(where: { $0.tag == MenuTag.appearanceMenu.rawValue }),
              let submenu = appearanceItem.submenu else { return }
        
        for item in submenu.items {
            if let menuData = item.representedObject as? AppearanceMenuData {
                item.state = (menuData.mode == currentMode) ? .on : .off
            }
        }
    }
}

private class AppearanceMenuData {
    let mode: AppearanceMode
    let handler: AppearanceMenuHandler
    
    init(mode: AppearanceMode, handler: AppearanceMenuHandler) {
        self.mode = mode
        self.handler = handler
    }
}

@objc private class AppearanceMenuHandler: NSObject {
    private let updateHandler: Selector
    private weak var target: AnyObject?
    
    init(target: AnyObject, updateHandler: Selector) {
        self.target = target
        self.updateHandler = updateHandler
        super.init()
    }
    
    @objc func appearanceChanged(_ sender: NSMenuItem) {
        guard let menuData = sender.representedObject as? AppearanceMenuData else { return }
        
        AppearanceManager.shared.setAppearance(menuData.mode)
        
        if let target = target {
            _ = target.perform(updateHandler)
        }
    }
}