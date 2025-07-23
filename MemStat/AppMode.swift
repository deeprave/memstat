import Foundation

enum AppMode: String, CaseIterable {
    case menubar = "menubar"
    case window = "window"
    
    var displayName: String {
        switch self {
        case .menubar: return "Menu Bar"
        case .window: return "Regular Window"
        }
    }
}