import XCTest
import Cocoa
@testable import MemStat

class AppearanceManagerTests: XCTestCase {
    
    var appearanceManager: AppearanceManager!
    var testMenu: NSMenu!
    var mockTarget: MockAppearanceTarget!
    
    override func setUp() {
        super.setUp()
        appearanceManager = AppearanceManager.shared
        testMenu = NSMenu()
        testMenu.addItem(NSMenuItem(title: "Test", action: nil, keyEquivalent: ""))
        mockTarget = MockAppearanceTarget()
        
        UserDefaults.standard.removeObject(forKey: "AppearanceMode")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "AppearanceMode")
        testMenu = nil
        mockTarget = nil
        super.tearDown()
    }
    
    // MARK: - Current Mode Tests
    
    func testDefaultCurrentMode() {
        XCTAssertEqual(appearanceManager.currentMode, .system)
    }
    
    func testCurrentModeGetterWithSavedPreference() {
        UserDefaults.standard.set("light", forKey: "AppearanceMode")
        XCTAssertEqual(appearanceManager.currentMode, .light)
        
        UserDefaults.standard.set("dark", forKey: "AppearanceMode")
        XCTAssertEqual(appearanceManager.currentMode, .dark)
    }
    
    func testCurrentModeSetterSavesToUserDefaults() {
        appearanceManager.currentMode = .light
        XCTAssertEqual(UserDefaults.standard.string(forKey: "AppearanceMode"), "light")
        
        appearanceManager.currentMode = .dark
        XCTAssertEqual(UserDefaults.standard.string(forKey: "AppearanceMode"), "dark")
    }
    
    func testCurrentModeInvalidValueFallsBackToSystem() {
        UserDefaults.standard.set("invalid_mode", forKey: "AppearanceMode")
        XCTAssertEqual(appearanceManager.currentMode, .system)
    }
    
    // MARK: - SetAppearance Tests
    
    func testSetAppearanceUpdatesCurrentMode() {
        appearanceManager.setAppearance(.light)
        XCTAssertEqual(appearanceManager.currentMode, .light)
        
        appearanceManager.setAppearance(.dark)
        XCTAssertEqual(appearanceManager.currentMode, .dark)
    }
    
    func testSetAppearanceUpdatesNSAppAppearance() {
        let originalAppearance = NSApp.appearance
        
        appearanceManager.setAppearance(.light)
        XCTAssertEqual(NSApp.appearance, NSAppearance(named: .aqua))
        
        appearanceManager.setAppearance(.dark)
        XCTAssertEqual(NSApp.appearance, NSAppearance(named: .darkAqua))
        
        appearanceManager.setAppearance(.system)
        XCTAssertNil(NSApp.appearance)
        
        NSApp.appearance = originalAppearance
    }
    
    func testSetAppearanceCallsUpdateAllAppearanceMenus() {
        appearanceManager.registerMenuForUpdates(testMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        mockTarget.updateCallCount = 0
        
        appearanceManager.setAppearance(.light)
        
        XCTAssertEqual(mockTarget.updateCallCount, 1)
    }
    
    // MARK: - Menu Creation Tests
    
    func testCreateAppearanceMenuStructure() {
        let appearanceItem = appearanceManager.createAppearanceMenu(target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        XCTAssertEqual(appearanceItem.title, "Appearance")
        XCTAssertEqual(appearanceItem.tag, MenuTag.appearanceMenu.rawValue)
        XCTAssertNotNil(appearanceItem.submenu)
        
        guard let submenu = appearanceItem.submenu else {
            XCTFail("Submenu should not be nil")
            return
        }
        
        XCTAssertEqual(submenu.items.count, AppearanceMode.allCases.count)
        
        let itemTitles = submenu.items.map { $0.title }
        XCTAssertTrue(itemTitles.contains("System"))
        XCTAssertTrue(itemTitles.contains("Light"))
        XCTAssertTrue(itemTitles.contains("Dark"))
    }
    
    func testCreateAppearanceMenuItemsHaveCorrectTargets() {
        let appearanceItem = appearanceManager.createAppearanceMenu(target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        guard let submenu = appearanceItem.submenu else {
            XCTFail("Submenu should not be nil")
            return
        }
        
        for item in submenu.items {
            XCTAssertNotNil(item.target)
            XCTAssertTrue(item.target is AppearanceMenuHandler)
            XCTAssertEqual(item.action, #selector(AppearanceMenuHandler.appearanceChanged(_:)))
            XCTAssertNotNil(item.representedObject)
            XCTAssertTrue(item.representedObject is AppearanceMenuData)
        }
    }
    
    func testCreateAppearanceMenuCurrentModeIsSelected() {
        appearanceManager.setAppearance(.light)
        
        let appearanceItem = appearanceManager.createAppearanceMenu(target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        guard let submenu = appearanceItem.submenu else {
            XCTFail("Submenu should not be nil")
            return
        }
        
        let lightItem = submenu.items.first { $0.title == "Light" }
        let darkItem = submenu.items.first { $0.title == "Dark" }
        let systemItem = submenu.items.first { $0.title == "System" }
        
        XCTAssertEqual(lightItem?.state, .on)
        XCTAssertEqual(darkItem?.state, .off)
        XCTAssertEqual(systemItem?.state, .off)
    }
    
    // MARK: - Menu Registration Tests
    
    func testRegisterMenuForUpdates() {
        appearanceManager.registerMenuForUpdates(testMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        appearanceManager.setAppearance(.dark)
        
        XCTAssertEqual(mockTarget.updateCallCount, 1)
    }
    
    func testMultipleMenuRegistration() {
        let secondMenu = NSMenu()
        secondMenu.addItem(NSMenuItem(title: "Test2", action: nil, keyEquivalent: ""))
        let secondTarget = MockAppearanceTarget()
        
        appearanceManager.registerMenuForUpdates(testMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        appearanceManager.registerMenuForUpdates(secondMenu, target: secondTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        appearanceManager.setAppearance(.light)
        
        XCTAssertEqual(mockTarget.updateCallCount, 1)
        XCTAssertEqual(secondTarget.updateCallCount, 1)
    }
    
    func testUnregisterMenuForUpdates() {
        appearanceManager.registerMenuForUpdates(testMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        appearanceManager.setAppearance(.dark)
        XCTAssertEqual(mockTarget.updateCallCount, 1)
        
        appearanceManager.unregisterMenuForUpdates(testMenu)
        mockTarget.updateCallCount = 0
        
        appearanceManager.setAppearance(.light)
        XCTAssertEqual(mockTarget.updateCallCount, 0)
    }
    
    func testUnregisterAllMenusForTarget() {
        let secondMenu = NSMenu()
        secondMenu.addItem(NSMenuItem(title: "Test2", action: nil, keyEquivalent: ""))
        
        appearanceManager.registerMenuForUpdates(testMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        appearanceManager.registerMenuForUpdates(secondMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        appearanceManager.setAppearance(.dark)
        XCTAssertEqual(mockTarget.updateCallCount, 2)
        
        appearanceManager.unregisterAllMenusForTarget(mockTarget)
        mockTarget.updateCallCount = 0
        
        appearanceManager.setAppearance(.light)
        XCTAssertEqual(mockTarget.updateCallCount, 0)
    }
    
    func testUnregisterMenuAfterMenuDeallocated() {
        weak var weakMenu: NSMenu?
        
        do {
            let tempMenu = NSMenu()
            tempMenu.addItem(NSMenuItem(title: "Temp", action: nil, keyEquivalent: ""))
            weakMenu = tempMenu
            
            appearanceManager.registerMenuForUpdates(tempMenu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        }
        
        XCTAssertNil(weakMenu)
        
        appearanceManager.setAppearance(.dark)
    }
    
    // MARK: - Update Menu Tests
    
    func testUpdateAppearanceMenuUpdatesItemStates() {
        let appearanceItem = appearanceManager.createAppearanceMenu(target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        testMenu.addItem(appearanceItem)
        
        appearanceManager.currentMode = .dark
        
        appearanceManager.updateAppearanceMenu(testMenu)
        
        guard let submenu = appearanceItem.submenu else {
            XCTFail("Submenu should not be nil")
            return
        }
        
        let lightItem = submenu.items.first { $0.title == "Light" }
        let darkItem = submenu.items.first { $0.title == "Dark" }
        let systemItem = submenu.items.first { $0.title == "System" }
        
        XCTAssertEqual(lightItem?.state, .off)
        XCTAssertEqual(darkItem?.state, .on)
        XCTAssertEqual(systemItem?.state, .off)
    }
    
    func testUpdateAppearanceMenuWithNoAppearanceItem() {
        appearanceManager.updateAppearanceMenu(testMenu)
    }
    
    func testUpdateAppearanceMenuWithIncorrectTag() {
        let wrongItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        wrongItem.tag = 999 // Wrong tag
        testMenu.addItem(wrongItem)
        
        appearanceManager.updateAppearanceMenu(testMenu)
    }
    
    // MARK: - Restore Appearance Tests
    
    func testRestoreAppearanceMode() {
        UserDefaults.standard.set("light", forKey: "AppearanceMode")
        
        let originalAppearance = NSApp.appearance
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        appearanceManager.restoreAppearanceMode()
        
        XCTAssertEqual(NSApp.appearance, NSAppearance(named: .aqua))
        
        NSApp.appearance = originalAppearance
    }
    
    // MARK: - Menu Handler Tests
    
    func testAppearanceMenuHandlerChangesAppearance() {
        let appearanceItem = appearanceManager.createAppearanceMenu(target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        guard let submenu = appearanceItem.submenu else {
            XCTFail("Submenu should not be nil")
            return
        }
        
        let darkItem = submenu.items.first { $0.title == "Dark" }
        XCTAssertNotNil(darkItem)
        
        if let target = darkItem?.target as? AppearanceMenuHandler,
           let action = darkItem?.action {
            target.perform(action, with: darkItem)
        }
        
        XCTAssertEqual(appearanceManager.currentMode, .dark)
    }
    
    func testAppearanceMenuHandlerCallsUpdateHandler() {
        mockTarget.updateCallCount = 0
        
        let appearanceItem = appearanceManager.createAppearanceMenu(target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        guard let submenu = appearanceItem.submenu else {
            XCTFail("Submenu should not be nil")
            return
        }
        
        let lightItem = submenu.items.first { $0.title == "Light" }
        XCTAssertNotNil(lightItem)
        
        if let target = lightItem?.target as? AppearanceMenuHandler,
           let action = lightItem?.action {
            target.perform(action, with: lightItem)
        }
        
        XCTAssertEqual(mockTarget.updateCallCount, 1)
    }
    
    // MARK: - Memory Management Tests
    
    func testWeakTargetReference() {
        var target: MockAppearanceTarget? = MockAppearanceTarget()
        let menu = NSMenu()
        
        appearanceManager.registerMenuForUpdates(menu, target: target!, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        target = nil
        
        appearanceManager.setAppearance(.light)
    }
    
    func testMenuCleanupOnUpdate() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Test3", action: nil, keyEquivalent: ""))
        appearanceManager.registerMenuForUpdates(menu, target: mockTarget, updateHandler: #selector(MockAppearanceTarget.updateAppearanceMenu))
        
        appearanceManager.setAppearance(.system)
        
        XCTAssertEqual(mockTarget.updateCallCount, 1)
    }
}

// MARK: - Mock Classes

@objc class MockAppearanceTarget: NSObject {
    var updateCallCount = 0
    
    @objc func updateAppearanceMenu() {
        updateCallCount += 1
    }
}