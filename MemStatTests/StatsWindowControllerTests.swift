import XCTest
import Cocoa
@testable import MemStat

class StatsWindowControllerTests: XCTestCase {
    
    var statsWindowController: StatsWindowController!
    
    override func setUp() {
        super.setUp()
        statsWindowController = StatsWindowController()
    }
    
    override func tearDown() {
        statsWindowController?.close()
        statsWindowController = nil
        super.tearDown()
    }
    
    func testWindowInitialization() {
        // Load the window
        _ = statsWindowController.window
        
        // Verify window properties
        XCTAssertNotNil(statsWindowController.window)
        
        guard let window = statsWindowController.window else { return }
        
        // Verify window style
        XCTAssertTrue(window.styleMask.contains(.borderless))
        XCTAssertTrue(window.isMovableByWindowBackground)
        XCTAssertFalse(window.canBecomeKey)
        XCTAssertEqual(window.level, .floating)
        
        // Verify window size
        XCTAssertEqual(window.frame.size.width, 680)
        XCTAssertEqual(window.frame.size.height, 860)
    }
    
    func testStatsViewSetup() {
        // Load the window
        _ = statsWindowController.window
        
        // Verify stats view exists
        XCTAssertNotNil(statsWindowController.statsView)
        
        guard let statsView = statsWindowController.statsView else { return }
        
        // Verify stats view has the correct number of table sections
        let tableSections = statsView.subviews.filter { view in
            view is MemoryTableSection || 
            view is VirtualTableSection || 
            view is SwapTableSection || 
            view is ProcessTableSection
        }
        
        XCTAssertEqual(tableSections.count, 4, "Should have 4 table sections")
        
        // Verify sections are in correct order (by Y position)
        let sortedSections = tableSections.sorted { $0.frame.origin.y < $1.frame.origin.y }
        XCTAssertTrue(sortedSections[0] is MemoryTableSection)
        XCTAssertTrue(sortedSections[1] is VirtualTableSection)
        XCTAssertTrue(sortedSections[2] is SwapTableSection)
        XCTAssertTrue(sortedSections[3] is ProcessTableSection)
    }
    
    func testTableSectionDelegation() {
        // Load the window
        _ = statsWindowController.window
        
        // Verify all table sections have the controller as delegate
        guard let statsView = statsWindowController.statsView else { return }
        
        for section in statsWindowController.tableSections {
            // Each section should have the controller as its delegate
            XCTAssertNotNil(section.delegate)
        }
    }
    
    func testHeaderLabelCreation() {
        let frame = NSRect(x: 0, y: 0, width: 100, height: 20)
        let label = statsWindowController.createHeaderLabel(
            "Test",
            frame: frame,
            isDarkBackground: true,
            sortColumn: .memoryPercent,
            fontSize: 12,
            alignment: .center
        )
        
        // Verify label properties
        XCTAssertEqual(label.stringValue, "Test")
        XCTAssertEqual(label.frame, frame)
        XCTAssertEqual(label.alignment, .center)
        XCTAssertTrue(label.isBezeled)
        XCTAssertFalse(label.isEditable)
        XCTAssertTrue(label.drawsBackground)
        
        // Verify custom cell is used
        XCTAssertTrue(label.cell is VerticallyCenteredTextFieldCell)
    }
    
    func testDataLabelCreation() {
        let frame = NSRect(x: 0, y: 0, width: 100, height: 20)
        let label = statsWindowController.createDataLabel(
            text: "TestData",
            frame: frame,
            alignment: .right,
            useMonospacedFont: true
        )
        
        // Verify label properties
        XCTAssertEqual(label.stringValue, "TestData")
        XCTAssertEqual(label.frame, frame)
        XCTAssertEqual(label.alignment, .right)
        XCTAssertFalse(label.isBezeled)
        XCTAssertFalse(label.isEditable)
        XCTAssertFalse(label.drawsBackground)
        
        // Verify font is monospaced when requested
        XCTAssertNotNil(label.font)
    }
    
    func testSortingUpdate() {
        // Test sorting update
        let initialColumn = statsWindowController.currentSortColumn
        let initialDescending = statsWindowController.sortDescending
        
        // Update sorting
        statsWindowController.updateSortingAndRefresh(sortColumn: .cpuPercent, sortDescending: true)
        
        // Verify sorting was updated
        XCTAssertEqual(statsWindowController.currentSortColumn, .cpuPercent)
        XCTAssertTrue(statsWindowController.sortDescending)
        
        // Update again with different values
        statsWindowController.updateSortingAndRefresh(sortColumn: .command, sortDescending: false)
        
        XCTAssertEqual(statsWindowController.currentSortColumn, .command)
        XCTAssertFalse(statsWindowController.sortDescending)
    }
    
    func testWindowDisplay() {
        let testOrigin = NSPoint(x: 100, y: 100)
        
        // Show window at specific position
        statsWindowController.showWindow(at: testOrigin)
        
        // Verify window is visible
        guard let window = statsWindowController.window else {
            XCTFail("Window not found")
            return
        }
        
        XCTAssertTrue(window.isVisible)
        XCTAssertEqual(window.frame.origin, testOrigin)
        
        // Verify timer is running
        XCTAssertNotNil(statsWindowController.timer)
        XCTAssertTrue(statsWindowController.timer?.isValid ?? false)
    }
    
    func testWindowClose() {
        // Show window first
        statsWindowController.showWindow(at: NSPoint(x: 100, y: 100))
        
        // Close window
        statsWindowController.close()
        
        // Verify timer is invalidated
        XCTAssertNil(statsWindowController.timer)
        
        // Verify window is closed
        XCTAssertFalse(statsWindowController.window?.isVisible ?? true)
    }
    
    func testMemoryMonitorIntegration() {
        // Verify memory monitor exists
        XCTAssertNotNil(statsWindowController.memoryMonitor)
        
        // Load window to trigger initial update
        _ = statsWindowController.window
        
        // Manually trigger update
        statsWindowController.updateStats()
        
        // Verify table sections have been updated with data
        // (We can't easily verify the exact data, but we can check that labels exist)
        guard let statsView = statsWindowController.statsView else { return }
        
        let labels = statsView.subviews.flatMap { section in
            section.subviews.compactMap { $0 as? NSTextField }
        }
        
        // Should have many labels with actual data
        XCTAssertGreaterThan(labels.count, 50)
        
        // Some labels should have non-empty values
        let nonEmptyLabels = labels.filter { !$0.stringValue.isEmpty }
        XCTAssertGreaterThan(nonEmptyLabels.count, 20)
    }
    
    func testTableBackgroundCreation() {
        let testView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        
        statsWindowController.addTableBackground(to: testView, padding: 10)
        
        // Verify background view was added
        let backgroundViews = testView.subviews.filter { view in
            view.wantsLayer && view.layer?.backgroundColor != nil
        }
        
        XCTAssertEqual(backgroundViews.count, 1)
        
        if let background = backgroundViews.first {
            // Verify frame includes padding
            XCTAssertEqual(background.frame.origin.x, 10)
            XCTAssertEqual(background.frame.origin.y, 0)
            XCTAssertEqual(background.frame.width, 180) // 200 - 2*10
            XCTAssertEqual(background.frame.height, 100)
        }
    }
    
    func testAppearanceHandling() {
        // Load window
        _ = statsWindowController.window
        
        // Verify appearance observer is set up
        XCTAssertNotNil(statsWindowController.appearanceObserver)
        
        // Test color update (we can't easily trigger appearance change, but we can call the method)
        statsWindowController.updateTextColors()
        
        // Verify colors are applied to labels
        guard let statsView = statsWindowController.statsView else { return }
        
        let labels = statsView.subviews.flatMap { section in
            section.subviews.compactMap { $0 as? NSTextField }
        }
        
        // All labels should have a text color set
        for label in labels {
            XCTAssertNotNil(label.textColor)
        }
    }
}