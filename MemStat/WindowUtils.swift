import Cocoa

enum WindowUtils {
    /// Brings a window to front, handling minimized/hidden states
    static func bringWindowToFront(_ window: NSWindow?) {
        guard let window = window else { return }
        
        if window.isMiniaturized {
            window.deminiaturize(nil)
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}