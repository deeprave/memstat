import Foundation
import ServiceManagement

class LoginItemsManager {
    static let shared = LoginItemsManager()
    
    private init() {}
    
    private var bundleIdentifier: String {
        return AppConstants.currentBundleIdentifier()
    }
    
    func isEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            let jobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: Any]]
            return jobDicts?.contains { dict in
                dict["Label"] as? String == bundleIdentifier
            } ?? false
        }
    }
    
    func enable() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
            } catch {
                print("Failed to register login item: \(error)")
            }
        } else {
            SMLoginItemSetEnabled(bundleIdentifier as CFString, true)
        }
    }
    
    func disable() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                print("Failed to unregister login item: \(error)")
            }
        } else {
            SMLoginItemSetEnabled(bundleIdentifier as CFString, false)
        }
    }
}