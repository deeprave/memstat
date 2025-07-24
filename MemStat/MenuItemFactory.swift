import Cocoa

enum MenuItemFactory {
    /// Creates a "Bring to Front" menu item with the specified target and action
    static func createBringToFrontItem(target: AnyObject, action: Selector) -> NSMenuItem {
        let bringToFrontItem = NSMenuItem(title: "Bring to Front", action: action, keyEquivalent: "")
        bringToFrontItem.target = target
        return bringToFrontItem
    }
}