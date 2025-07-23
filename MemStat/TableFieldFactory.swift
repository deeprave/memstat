import Cocoa
import Foundation

class TableFieldFactory {
    private let labelFactory: LabelFactory
    
    init(labelFactory: LabelFactory) {
        self.labelFactory = labelFactory
    }
    
    func createMetricField(label: String, hasUnits: Bool, rowIndex: Int, sectionHeight: CGFloat, section: NSView, labelWidth: CGFloat = TableLayoutManager.VerticalTableLayout.labelWidth) -> [NSTextField] {
        let rowY = TableLayoutManager.VerticalTableLayout.rowY(rowIndex: rowIndex, sectionHeight: sectionHeight)
        var fields: [NSTextField] = []
        
        let labelView = labelFactory.createRowLabel(
            text: label,
            frame: NSRect(
                x: TableLayoutManager.VerticalTableLayout.labelX(),
                y: rowY,
                width: labelWidth,
                height: TableLayoutManager.VerticalTableLayout.rowHeight
            ),
            alignment: .right
        )
        section.addSubview(labelView)
        
        if hasUnits {
            let customValueX = labelWidth + TableLayoutManager.VerticalTableLayout.labelValueSpacing
            let valueWidth = labelWidth == TableLayoutManager.VerticalTableLayout.labelWidth ? 
                TableLayoutManager.VerticalTableLayout.valueWidth - TableLayoutManager.VerticalTableLayout.unitWidth - 5 :
                TableLayoutManager.VerticalTableLayout.valueWidth - TableLayoutManager.VerticalTableLayout.unitWidth - 5 + 5
            
            let valueLabel = labelFactory.createDataLabel(
                text: "Loading...",
                frame: NSRect(
                    x: customValueX,
                    y: rowY,
                    width: valueWidth,
                    height: TableLayoutManager.VerticalTableLayout.rowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            
            let unitLabel = labelFactory.createDataLabel(
                text: "",
                frame: NSRect(
                    x: customValueX + valueWidth,
                    y: rowY,
                    width: 26,
                    height: TableLayoutManager.VerticalTableLayout.rowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            
            section.addSubview(valueLabel)
            section.addSubview(unitLabel)
            fields.append(valueLabel)
            fields.append(unitLabel)
        } else {
            let unitFieldRightEdge = TableLayoutManager.VerticalTableLayout.unitX() + 26
            let fieldWidth = TableLayoutManager.VerticalTableLayout.valueWidth
            let fieldX = unitFieldRightEdge - fieldWidth
            
            let valueLabel = labelFactory.createDataLabel(
                text: "Loading...",
                frame: NSRect(
                    x: fieldX,
                    y: rowY,
                    width: fieldWidth,
                    height: TableLayoutManager.VerticalTableLayout.rowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            
            section.addSubview(valueLabel)
            fields.append(valueLabel)
        }
        
        return fields
    }
}