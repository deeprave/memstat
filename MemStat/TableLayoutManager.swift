import Cocoa
import Foundation

class TableLayoutManager {
    static let shared = TableLayoutManager()
    
    private init() {}
    
    func calculateWindowHeight() -> CGFloat {
        return VerticalTableLayout.topMargin + 
               VerticalTableLayout.calculateTableHeight(for: 7) + 
               VerticalTableLayout.tableProcessSpacing + 
               VerticalTableLayout.processTableHeight + 
               VerticalTableLayout.bottomMargin
    }
    
    func calculateTablePositions(windowHeight: CGFloat) -> (memory: CGFloat, virtual: CGFloat, swap: CGFloat, process: CGFloat) {
        let tableHeight = VerticalTableLayout.calculateTableHeight(for: 7)
        let tablesY = windowHeight - VerticalTableLayout.topMargin - tableHeight
        let processY = tablesY - VerticalTableLayout.tableProcessSpacing - VerticalTableLayout.processTableHeight
        
        return (memory: tablesY, virtual: tablesY, swap: tablesY, process: processY)
    }
    
    func createTableSections(windowHeight: CGFloat) -> [BaseTableSection] {
        let positions = calculateTablePositions(windowHeight: windowHeight)
        
        return [
            MemoryTableSection(yPosition: positions.memory),
            VirtualTableSection(yPosition: positions.virtual),
            SwapTableSection(yPosition: positions.swap),
            ProcessTableSection(yPosition: positions.process)
        ]
    }
    
    func createMemorySection(yPosition: CGFloat, in parentView: NSView) -> BaseTableSection {
        return MemoryTableSection(yPosition: yPosition)
    }
    
    func createVirtualSection(yPosition: CGFloat, in parentView: NSView) -> BaseTableSection {
        return VirtualTableSection(yPosition: yPosition)
    }
    
    func createSwapSection(yPosition: CGFloat, in parentView: NSView) -> BaseTableSection {
        return SwapTableSection(yPosition: yPosition)
    }
    
    func createProcessSection(yPosition: CGFloat, in parentView: NSView) -> BaseTableSection {
        return ProcessTableSection(yPosition: yPosition)
    }
    
    func createTableBackground(for section: NSView, padding: CGFloat) {
        let backgroundFrame = section.bounds.insetBy(dx: -padding, dy: -padding)
        
        let shadowFrame = backgroundFrame.offsetBy(dx: 4, dy: -4)
        let shadowView = NSView(frame: shadowFrame)
        shadowView.wantsLayer = true
        
        let shadowColor = NSColor(name: "TableShadow") { appearance in
            switch appearance.name {
            case .aqua, .vibrantLight:
                return NSColor.black.withAlphaComponent(0.25)
            case .darkAqua, .vibrantDark:
                return NSColor.white.withAlphaComponent(0.4)
            default:
                return NSColor.black.withAlphaComponent(0.25)
            }
        }
        
        shadowView.layer?.backgroundColor = shadowColor.cgColor
        shadowView.layer?.cornerRadius = 10.0
        shadowView.layer?.masksToBounds = true
        
        let backgroundView = NSView(frame: backgroundFrame)
        backgroundView.wantsLayer = true
        let whiteColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backgroundView.layer?.backgroundColor = whiteColor
        backgroundView.layer?.cornerRadius = 10.0
        backgroundView.layer?.masksToBounds = true
        
        section.addSubview(backgroundView, positioned: .below, relativeTo: nil)
        section.addSubview(shadowView, positioned: .below, relativeTo: backgroundView)
    }
}