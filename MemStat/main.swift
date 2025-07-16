import Cocoa

func isRunningTests() -> Bool {
    return NSClassFromString("XCTestCase") != nil
}

if !isRunningTests() {
    let runningApps = NSWorkspace.shared.runningApplications
    let currentBundleId = Bundle.main.bundleIdentifier ?? "io.uniquode.MemStat"
    
    let otherInstances = runningApps.filter { app in
        return app.bundleIdentifier == currentBundleId && app != NSRunningApplication.current
    }
    
    if !otherInstances.isEmpty {
        for instance in otherInstances {
            instance.activate(options: [])
        }
        exit(0)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()