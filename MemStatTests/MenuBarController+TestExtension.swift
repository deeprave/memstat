import AppKit
@testable import MemStat

// Test-only extension for MenuBarController to provide access to private properties
extension MenuBarController {
    func testOnlyGetContextMenu() -> NSMenu? {
        return contextMenu
    }
    
    func testOnlyGetStatsWindowController() -> StatsWindowController? {
        return statsWindowController
    }
}