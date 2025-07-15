//
//  FormatUtilities.swift
//  MemStat
//
//  Created by David L Nugent on 14/7/2025.
//

import Foundation

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
}