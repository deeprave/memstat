import Cocoa

protocol AppearanceMenuUpdateDelegate: AnyObject {
    func updateAppearanceMenu()
}

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

private class WeakMenuReference {
    weak var menu: NSMenu?
    
    init(menu: NSMenu) {
        self.menu = menu
    }
}

private class WeakDelegateReference {
    weak var delegate: AppearanceMenuUpdateDelegate?
    
    init(delegate: AppearanceMenuUpdateDelegate) {
        self.delegate = delegate
    }
}

class AppearanceManager {
    static let shared = AppearanceManager()
    
    private let userDefaultsKey = "AppearanceMode"
    private var registeredMenus: [(weakMenu: WeakMenuReference, weakDelegate: WeakDelegateReference, updateHandler: () -> Void)] = []
    
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
    
    func createAppearanceMenu(delegate: AppearanceMenuUpdateDelegate) -> NSMenuItem {
        let appearanceItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        appearanceItem.tag = MenuTag.appearanceMenu.rawValue
        let appearanceSubmenu = NSMenu()
        let menuHandler = AppearanceMenuHandler(delegate: delegate)
        
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
    
    func registerMenuForUpdates(_ menu: NSMenu, delegate: AppearanceMenuUpdateDelegate) {
        let weakMenuRef = WeakMenuReference(menu: menu)
        let weakDelegateRef = WeakDelegateReference(delegate: delegate)
        let updateClosure = { [weak self, weakMenuRef, weakDelegateRef] in
            guard let self = self, let delegate = weakDelegateRef.delegate, let menu = weakMenuRef.menu else { return }
            self.updateAppearanceMenu(menu)
            delegate.updateAppearanceMenu()
        }
        registeredMenus.append((weakMenu: weakMenuRef, weakDelegate: weakDelegateRef, updateHandler: updateClosure))
    }
    
    func unregisterMenuForUpdates(_ menu: NSMenu) {
        registeredMenus.removeAll { entry in
            guard let registeredMenu = entry.weakMenu.menu else { return true }
            return registeredMenu === menu
        }
    }
    
    func unregisterAllMenusForDelegate(_ delegate: AppearanceMenuUpdateDelegate) {
        registeredMenus.removeAll { entry in
            guard let registeredDelegate = entry.weakDelegate.delegate else { return true }
            return registeredDelegate === delegate
        }
    }
    
    private func updateAllAppearanceMenus() {
        registeredMenus = registeredMenus.compactMap { entry in
            guard let menu = entry.weakMenu.menu else { return nil }
            guard entry.weakDelegate.delegate != nil else { return nil }
            guard menu.supermenu != nil || menu.numberOfItems > 0 else { return nil }
            return entry
        }
        
        for entry in registeredMenus {
            entry.updateHandler()
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

class AppearanceMenuData {
    let mode: AppearanceMode
    let handler: AppearanceMenuHandler
    
    init(mode: AppearanceMode, handler: AppearanceMenuHandler) {
        self.mode = mode
        self.handler = handler
    }
}

@objc class AppearanceMenuHandler: NSObject {
    weak var delegate: AppearanceMenuUpdateDelegate?
    
    init(delegate: AppearanceMenuUpdateDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    @objc func appearanceChanged(_ sender: NSMenuItem) {
        guard let menuData = sender.representedObject as? AppearanceMenuData else { return }
        
        AppearanceManager.shared.setAppearance(menuData.mode)
        
        delegate?.updateAppearanceMenu()
    }
}