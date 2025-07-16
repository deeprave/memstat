import Cocoa

class StatsThemeManager {
    static let shared = StatsThemeManager()
    
    private init() {}
    
    func applyTheme(to view: NSView) {
        view.needsDisplay = true
        view.subviews.forEach { $0.needsDisplay = true }
        
        updateBorderColors(in: view)
        updateTableBackgrounds(in: view)
        updateTextColors(in: view)
    }
    
    func getCurrentAppearance(for window: NSWindow?) -> NSAppearance {
        return window?.effectiveAppearance ?? NSApp.effectiveAppearance
    }
    
    func isDarkMode(appearance: NSAppearance) -> Bool {
        return appearance.name == .darkAqua || appearance.name == .vibrantDark
    }
    
    private func updateBorderColors(in view: NSView) {
        view.subviews.forEach { section in
            section.subviews.forEach { subview in
                if subview.frame.width == 1 || subview.frame.height == 1 {
                    subview.layer?.backgroundColor = ColorTheme.borderColor.cgColor
                }
            }
        }
    }
    
    private func updateTableBackgrounds(in view: NSView) {
        view.subviews.forEach { section in
            if let backgroundView = section.subviews.first,
               backgroundView.layer?.cornerRadius == 10.0 {
                backgroundView.layer?.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    private func updateTextColors(in view: NSView) {
        view.subviews.forEach { section in
            let isProcessSection = section.subviews.filter { $0 is NSTextField }.count > 50
            
            section.subviews.forEach { subview in
                if let textField = subview as? NSTextField {
                    if isProcessSection {
                        if textField.cell is VerticallyCenteredTextFieldCell {
                            textField.textColor = ColorTheme.tableHeaderText
                        } else if textField.stringValue == "Top Processes" {
                            textField.textColor = ColorTheme.alwaysDarkText
                        } else {
                            textField.textColor = ColorTheme.alwaysDarkText
                        }
                    } else {
                        if textField.cell is VerticallyCenteredTextFieldCell {
                            textField.textColor = ColorTheme.tableHeaderText
                        } else if textField.stringValue.contains("Memory") || textField.stringValue.contains("Virtual") || textField.stringValue.contains("Swap") {
                            textField.textColor = ColorTheme.alwaysDarkText
                        } else {
                            let pressureValues = ["Normal", "Warning", "Critical"]
                            if !pressureValues.contains(textField.stringValue) {
                                textField.textColor = ColorTheme.alwaysDarkText
                            }
                        }
                    }
                }
                if let textField = subview as? NSTextField,
                   let cell = textField.cell as? VerticallyCenteredTextFieldCell {
                    cell.textColor = ColorTheme.tableHeaderText
                    cell.customBackgroundColor = ColorTheme.tableHeaderBackground
                }
            }
        }
    }
}