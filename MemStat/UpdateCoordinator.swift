import Foundation

class UpdateCoordinator {
    private var timer: Timer?
    private let updateInterval: TimeInterval
    private let updateHandler: () -> Void
    
    init(updateInterval: TimeInterval, updateHandler: @escaping () -> Void) {
        self.updateInterval = updateInterval
        self.updateHandler = updateHandler
    }
    
    func startUpdating() {
        stopUpdating()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateHandler()
        }
    }
    
    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }
}