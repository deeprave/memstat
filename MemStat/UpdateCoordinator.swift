import Foundation

class UpdateCoordinator {
    private var timer: Timer?
    private let updateInterval: TimeInterval
    private let updateHandler: () -> Void
    
    init(updateInterval: TimeInterval, updateHandler: @escaping () -> Void) {
        self.updateInterval = updateInterval
        self.updateHandler = updateHandler
    }
    
    func startUpdating(immediate: Bool = false) {
        stopUpdating()
        if immediate {
            updateHandler()
        }
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateHandler()
        }
        
        // Schedule on main run loop with common modes for UI thread safety
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }
}