import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var menuBarController: MenuBarController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

