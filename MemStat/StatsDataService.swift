import Foundation
import Cocoa


class StatsDataService: SortHandler {
    private let memoryMonitor: MemoryMonitor
    internal var currentSortColumn: ProcessSortColumn
    internal var sortDescending: Bool
    
    weak var sortHandler: SortHandler?
    
    init(memoryMonitor: MemoryMonitor? = nil, sortColumn: ProcessSortColumn = .memoryPercent, sortDescending: Bool = true) {
        self.memoryMonitor = memoryMonitor ?? MemoryMonitor()
        self.currentSortColumn = sortColumn
        self.sortDescending = sortDescending
    }
    
    func getCurrentStats() -> MemoryStats {
        return memoryMonitor.getMemoryStats(sortBy: currentSortColumn, sortDescending: sortDescending)
    }
    
    func updateSortingAndRefresh(sortColumn: ProcessSortColumn, sortDescending: Bool) {
        self.currentSortColumn = sortColumn
        self.sortDescending = sortDescending
        sortHandler?.updateSortingAndRefresh(sortColumn: sortColumn, sortDescending: sortDescending)
    }
    
    func getCurrentSortColumn() -> ProcessSortColumn {
        return currentSortColumn
    }
    
    func isSortDescending() -> Bool {
        return sortDescending
    }
}