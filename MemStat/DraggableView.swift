import Cocoa

class DraggableView: NSView {
    private var initialLocation: NSPoint = NSZeroPoint
    private var isDragging: Bool = false
    
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
        var newOrigin = NSPoint(
            x: window.frame.origin.x + (currentLocation.x - initialLocation.x),
            y: window.frame.origin.y + (currentLocation.y - initialLocation.y)
        )
        
        // Calculate the combined visible area of all screens to allow multi-monitor dragging
        let allScreens = NSScreen.screens
        guard !allScreens.isEmpty else {
            window.setFrameOrigin(newOrigin)
            return
        }
        
        let windowFrame = window.frame
        
        // Find the bounds that encompass all screens
        var combinedFrame = allScreens[0].visibleFrame
        for screen in allScreens.dropFirst() {
            combinedFrame = combinedFrame.union(screen.visibleFrame)
        }
        
        // Ensure at least part of the window remains visible (allow 50 points of window to be off-screen)
        let minVisibleMargin: CGFloat = 50
        let minX = combinedFrame.minX - windowFrame.width + minVisibleMargin
        let maxX = combinedFrame.maxX - minVisibleMargin
        let minY = combinedFrame.minY - windowFrame.height + minVisibleMargin
        let maxY = combinedFrame.maxY - minVisibleMargin
        
        // Clamp the new position
        newOrigin.x = min(max(newOrigin.x, minX), maxX)
        newOrigin.y = min(max(newOrigin.y, minY), maxY)
        
        window.setFrameOrigin(newOrigin)
    }
    
    override func mouseUp(with event: NSEvent) {
        if isDragging {
            isDragging = false
        } else {
            super.mouseUp(with: event)
        }
    }
    
    private func shouldAllowDraggingAt(point: NSPoint) -> Bool {
        let hitView = hitTest(point)
        
        // List of interactive controls to exclude from dragging
        let interactiveTypes: [AnyClass] = [
            NSTextField.self,
            NSButton.self,
            NSSlider.self,
            NSComboBox.self,
            NSPopUpButton.self,
            NSSegmentedControl.self,
            NSScrollView.self
        ]
        
        if let hitView = hitView {
            for type in interactiveTypes {
                if hitView.isKind(of: type) {
                    return false
                }
            }
        }
        
        // Allow dragging from any non-interactive subview
        return true
    }
}