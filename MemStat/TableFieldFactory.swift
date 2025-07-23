import Cocoa
import Foundation

class TableFieldFactory {
    private let labelFactory: LabelFactory
    
    init(labelFactory: LabelFactory) {
        self.labelFactory = labelFactory
    }
    
    func createMetricField(label: String, hasUnits: Bool, rowIndex: Int, sectionHeight: CGFloat, section: NSView, labelWidth: CGFloat = VerticalTableLayout.labelWidth) -> [NSTextField] {
        let rowY = VerticalTableLayout.rowY(rowIndex: rowIndex, sectionHeight: sectionHeight)
        var fields: [NSTextField] = []
        
        let labelView = labelFactory.createRowLabel(
            text: label,
            frame: NSRect(
                x: VerticalTableLayout.labelX(),
                y: rowY,
                width: labelWidth,
                height: VerticalTableLayout.rowHeight
            ),
            alignment: .right
        )
        section.addSubview(labelView)
        
        if hasUnits {
            let customValueX = labelWidth + VerticalTableLayout.labelValueSpacing
            let valueWidth = labelWidth == VerticalTableLayout.labelWidth ? 
                VerticalTableLayout.valueWidth - VerticalTableLayout.unitWidth - 5 :
                VerticalTableLayout.valueWidth - VerticalTableLayout.unitWidth - 5 + 5
            
            let valueLabel = labelFactory.createDataLabel(
                text: "Loading...",
                frame: NSRect(
                    x: customValueX,
                    y: rowY,
                    width: valueWidth,
                    height: VerticalTableLayout.rowHeight
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
                    height: VerticalTableLayout.rowHeight
                ),
                alignment: .right,
                useMonospacedFont: false
            )
            
            section.addSubview(valueLabel)
            section.addSubview(unitLabel)
            fields.append(valueLabel)
            fields.append(unitLabel)
        } else {
            let unitFieldRightEdge = VerticalTableLayout.unitX() + 26
            let fieldWidth = VerticalTableLayout.valueWidth
            let fieldX = unitFieldRightEdge - fieldWidth
            
            let valueLabel = labelFactory.createDataLabel(
                text: "Loading...",
                frame: NSRect(
                    x: fieldX,
                    y: rowY,
                    width: fieldWidth,
                    height: VerticalTableLayout.rowHeight
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