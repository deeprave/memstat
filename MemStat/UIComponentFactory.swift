import Cocoa
import Foundation

class UIComponentFactory: LabelFactory, BackgroundStylist {
    private var currentSortColumn: ProcessSortColumn?
    private var sortDescending: Bool
    
    init(currentSortColumn: ProcessSortColumn? = nil, sortDescending: Bool = false) {
        self.currentSortColumn = currentSortColumn
        self.sortDescending = sortDescending
    }
    
    private func monospacedFont(ofSize size: CGFloat) -> NSFont {
        if #available(macOS 10.15, *) {
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        } else {
            return NSFont(name: "Menlo", size: size) ?? NSFont.userFixedPitchFont(ofSize: size) ?? NSFont.systemFont(ofSize: size)
        }
    }
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment, isSortColumn: Bool) -> NSTextField {
        let displayText: String
        if isSortColumn && sortColumn != nil {
            let arrow = sortDescending ? "▼" : "▲"
            displayText = "\(text) \(arrow)"
        } else {
            displayText = text
        }
        
        let label = NSTextField(frame: frame)
        label.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        label.alignment = alignment
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.backgroundColor = .clear
        label.drawsBackground = false
        
        let cell = VerticallyCenteredTextFieldCell(textCell: displayText)
        cell.font = NSFont.systemFont(ofSize: 14, weight: .bold)
        cell.alignment = alignment
        cell.customBackgroundColor = TableStyling.headerBackgroundColor
        
        label.cell = cell
        label.stringValue = displayText
        
        if isSortColumn {
            label.textColor = NSColor.systemYellow
            cell.textColor = NSColor.systemYellow
        } else {
            label.textColor = TableStyling.headerTextColor
            cell.textColor = TableStyling.headerTextColor
        }
       
        return label
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = useMonospacedFont ? monospacedFont(ofSize: 17) : NSFont.systemFont(ofSize: 17)
        label.textColor = TableStyling.dataTextColor
        label.frame = frame
        label.alignment = alignment
        label.cell?.alignment = alignment
        return label
    }
    
    func createProcessDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = useMonospacedFont ? monospacedFont(ofSize: 12) : NSFont.systemFont(ofSize: 12)
        label.textColor = TableStyling.dataTextColor
        label.frame = frame
        label.alignment = alignment
        label.cell?.alignment = alignment
        return label
    }
    
    func createRowLabel(text: String, frame: NSRect, alignment: NSTextAlignment) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = ColorTheme.alwaysDarkText
        label.frame = frame
        label.alignment = alignment
        label.cell?.alignment = alignment
        return label
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        TableLayoutManager.shared.createTableBackground(for: section, padding: padding)
    }
}
