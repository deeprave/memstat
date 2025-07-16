import Cocoa
import Foundation

class UIComponentFactory: LabelFactory, BackgroundStylist {
    private let currentSortColumn: ProcessSortColumn
    private let sortDescending: Bool
    
    init(currentSortColumn: ProcessSortColumn, sortDescending: Bool) {
        self.currentSortColumn = currentSortColumn
        self.sortDescending = sortDescending
    }
    
    func createHeaderLabel(_ text: String, frame: NSRect, isDarkBackground: Bool, sortColumn: ProcessSortColumn?, fontSize: CGFloat, alignment: NSTextAlignment) -> NSTextField {
        let displayText = FormatUtilities.createSortableHeaderText(text, sortColumn: sortColumn, currentSortColumn: currentSortColumn, sortDescending: sortDescending)
        
        let label = NSTextField(frame: frame)
        label.stringValue = displayText
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
        
        if isDarkBackground {
            let isActiveSortColumn = sortColumn != nil && sortColumn == currentSortColumn
            
            if isActiveSortColumn {
                label.textColor = NSColor.systemYellow
                cell.textColor = NSColor.systemYellow
                cell.customBackgroundColor = TableStyling.headerBackgroundColor
            } else {
                label.textColor = TableStyling.headerTextColor
                cell.textColor = TableStyling.headerTextColor
                cell.customBackgroundColor = TableStyling.headerBackgroundColor
            }
            cell.customBorderColor = TableStyling.borderColor
        } else {
            let isActiveSortColumn = sortColumn != nil && sortColumn == currentSortColumn
            
            if isActiveSortColumn {
                label.textColor = NSColor.systemYellow
                cell.textColor = NSColor.systemYellow
            } else {
                label.textColor = ColorTheme.alwaysDarkText
                cell.textColor = ColorTheme.alwaysDarkText
            }
        }
        
        label.cell = cell
        
        return label
    }
    
    func createDataLabel(text: String, frame: NSRect, alignment: NSTextAlignment, useMonospacedFont: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = useMonospacedFont ? NSFont.monospacedSystemFont(ofSize: 17, weight: .regular) : NSFont.systemFont(ofSize: 17)
        label.textColor = TableStyling.dataTextColor
        label.frame = frame
        label.alignment = alignment
        return label
    }
    
    func addTableBackground(to section: NSView, padding: CGFloat) {
        TableLayoutManager.shared.createTableBackground(for: section, padding: padding)
    }
}