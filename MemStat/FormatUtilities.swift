import Foundation
import Cocoa

struct FormatUtilities {
    
    private static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB, .useBytes]
        formatter.countStyle = .memory
        return formatter
    }()
    
    static func formatBytes(_ bytes: UInt64) -> String {
        let formatted = byteFormatter.string(fromByteCount: Int64(bytes))
        return formatted.replacingOccurrences(of: " bytes", with: " b")
    }
    
    static func separateValueAndUnit(_ formattedString: String) -> (value: String, unit: String) {
        let components = formattedString.components(separatedBy: " ")
        if components.count >= 2 {
            let value = components[0]
            let unit = components[1]
            return (value: value, unit: unit)
        } else {
            return (value: formattedString, unit: "")
        }
    }
    
    static func createSortableHeaderText(_ text: String, sortColumn: ProcessSortColumn?, currentSortColumn: ProcessSortColumn?, sortDescending: Bool) -> String {
        guard let sortColumn = sortColumn,
              let currentSort = currentSortColumn,
              sortColumn == currentSort else {
            return text
        }
        
        let arrow = sortDescending ? "▼" : "▲"
        return "\(text) \(arrow)"
    }
    
    static func formatCount(_ count: UInt64) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000.0)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000.0)
        } else {
            return String(count)
        }
    }
    
    static func createPinIcon(appearance: NSAppearance) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let pinColor = getPinButtonColor(appearance: appearance)
        
        let headCenter = NSPoint(x: 14, y: 16)
        let headRadius: CGFloat = 4.0
        let headPath = NSBezierPath()
        headPath.appendArc(withCenter: headCenter, radius: headRadius, startAngle: 0, endAngle: 360)
        
        let bodyPath = NSBezierPath()
        bodyPath.move(to: NSPoint(x: 11.5, y: 13.5))
        bodyPath.line(to: NSPoint(x: 9.5, y: 9.5))
        bodyPath.line(to: NSPoint(x: 10.5, y: 8.5))
        bodyPath.line(to: NSPoint(x: 12.5, y: 12.5))
        bodyPath.close()
        
        let pointPath = NSBezierPath()
        pointPath.move(to: NSPoint(x: 9.5, y: 9.5))
        pointPath.line(to: NSPoint(x: 8, y: 8))
        pointPath.line(to: NSPoint(x: 10.5, y: 8.5))
        pointPath.close()
        
        pinColor.setFill()
        headPath.fill()
        bodyPath.fill()
        pointPath.fill()
        
        pinColor.setStroke()
        headPath.lineWidth = 0.5
        bodyPath.lineWidth = 0.5
        pointPath.lineWidth = 0.5
        
        headPath.stroke()
        bodyPath.stroke()
        pointPath.stroke()
        
        image.unlockFocus()
        
        return image
    }
    
    static func createCloseIcon(appearance: NSAppearance) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let path = NSBezierPath()
        
        path.move(to: NSPoint(x: 6, y: 16))
        path.line(to: NSPoint(x: 16, y: 6))
        path.move(to: NSPoint(x: 16, y: 16))
        path.line(to: NSPoint(x: 6, y: 6))
        
        getPinButtonColor(appearance: appearance).setStroke()
        path.lineWidth = 2.5
        path.stroke()
        
        image.unlockFocus()
        
        return image
    }
    
    private static func getPinButtonColor(appearance: NSAppearance) -> NSColor {
        return appearance.name == .darkAqua || appearance.name == .vibrantDark ? .white : .black
    }
}