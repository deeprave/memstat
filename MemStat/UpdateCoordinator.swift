import Foundation

class UpdateCoordinator {
    private var timer: Timer?
    private let updateInterval: TimeInterval
    private let updateHandler: () -> Void
    
    private static let minimumUpdateInterval: TimeInterval = 0.1
    
    init(updateInterval: TimeInterval, updateHandler: @escaping () -> Void) {
        self.updateInterval = max(updateInterval, Self.minimumUpdateInterval)
        self.updateHandler = updateHandler
    }
    
    func startUpdating(immediate: Bool = false) {
        stopUpdating()
        if immediate {
            updateHandler()
        }
        timer = Timer(timeInterval: updateInterval, repeats: true) { [weak self] _ in
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