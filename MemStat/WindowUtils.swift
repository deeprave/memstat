import Cocoa

enum WindowUtils {
    /// Brings a window to front, handling minimized/hidden states
    static func bringWindowToFront(_ window: NSWindow?) {
        guard let window = window else { return }
        
        if window.isMiniaturized {
            window.deminiaturize(nil)
        }
        if !window.isVisible {
            window.orderFront(nil)
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}