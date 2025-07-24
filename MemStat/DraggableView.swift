import Cocoa

// Protocol for custom/third-party controls to opt out of dragging
@objc protocol DraggableExclusion {}

class DraggableView: NSView {
    private var initialLocation: NSPoint = NSZeroPoint
    private var isDragging: Bool = false
    
    // Default list of interactive controls to exclude from dragging
    private static let defaultInteractiveTypes: [AnyClass] = [
        NSTextField.self,
        NSButton.self,
        NSSlider.self,
        NSComboBox.self,
        NSPopUpButton.self,
        NSSegmentedControl.self,
        NSScrollView.self
    ]
    
    // Configurable list of interactive controls to exclude from dragging
    var interactiveTypes: [AnyClass] = DraggableView.defaultInteractiveTypes
    
    override func mouseDown(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        
        if shouldAllowDraggingAt(point: locationInView) {
            initialLocation = event.locationInWindow
            isDragging = true
        } else {
            super.mouseDown(with: event)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isDragging, let window = self.window else {
            super.mouseDragged(with: event)
            return
        }
        
        let currentLocation = event.locationInWindow
        let newOrigin = NSPoint(
            x: window.frame.origin.x + (currentLocation.x - initialLocation.x),
            y: window.frame.origin.y + (currentLocation.y - initialLocation.y)
        )
        
        // Calculate the combined visible area of all screens to allow multi-monitor dragging
        guard let screenBounds = combinedScreenBounds() else {
            window.setFrameOrigin(newOrigin)
            return
        }
        
        let clampedOrigin = clampedOrigin(newOrigin, windowFrame: window.frame, screenBounds: screenBounds)
        window.setFrameOrigin(clampedOrigin)
    }
    
    override func mouseUp(with event: NSEvent) {
        if isDragging {
            isDragging = false
            initialLocation = NSZeroPoint
        } else {
            super.mouseUp(with: event)
        }
    }
    
    private func shouldAllowDraggingAt(point: NSPoint) -> Bool {
        let hitView = hitTest(point)
        
        // Check if the hit view or any of its superviews should be excluded from dragging
        var view: NSView? = hitView
        while let currentView = view {
            for type in interactiveTypes {
                if currentView.isKind(of: type) {
                    return false
                }
            }
            if currentView.conforms(to: DraggableExclusion.self) {
                return false
            }
            view = currentView.superview
        }
        
        // Allow dragging from any non-interactive subview
        return true
    }
    
    private func combinedScreenBounds() -> NSRect? {
        let allScreens = NSScreen.screens
        guard !allScreens.isEmpty else { return nil }
        
        // Find the bounds that encompass all screens
        var combinedFrame = allScreens[0].visibleFrame
        for screen in allScreens.dropFirst() {
            combinedFrame = combinedFrame.union(screen.visibleFrame)
        }
        return combinedFrame
    }
    
    private func clampedOrigin(_ newOrigin: NSPoint, windowFrame: NSRect, screenBounds: NSRect) -> NSPoint {
        // Ensure at least part of the window remains visible (allow 50 points of window to be off-screen)
        let minVisibleMargin: CGFloat = 50
        let minX = screenBounds.minX - windowFrame.width + minVisibleMargin
        let maxX = screenBounds.maxX - minVisibleMargin
        let minY = screenBounds.minY - windowFrame.height + minVisibleMargin
        let maxY = screenBounds.maxY - minVisibleMargin
        
        return NSPoint(
            x: min(max(newOrigin.x, minX), maxX),
            y: min(max(newOrigin.y, minY), maxY)
        )
    }
}