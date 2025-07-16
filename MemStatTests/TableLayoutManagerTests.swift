import XCTest
import Cocoa
@testable import MemStat

class TableLayoutManagerTests: XCTestCase {
    
    var layoutManager: TableLayoutManager!
    var parentView: NSView!
    
    override func setUp() {
        super.setUp()
        layoutManager = TableLayoutManager.shared
        parentView = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    }
    
    override func tearDown() {
        layoutManager = nil
        parentView = nil
        super.tearDown()
    }
    
    func testSharedInstance() {
        let instance1 = TableLayoutManager.shared
        let instance2 = TableLayoutManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testCalculateWindowHeight() {
        let height = layoutManager.calculateWindowHeight()
        let expectedHeight = VerticalTableLayout.topMargin + 
                           VerticalTableLayout.calculateTableHeight(for: 7) + 
                           VerticalTableLayout.tableProcessSpacing + 
                           VerticalTableLayout.processTableHeight + 
                           VerticalTableLayout.bottomMargin
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testCreateMemorySection() {
        let yPosition: CGFloat = 100
        let section = layoutManager.createMemorySection(yPosition: yPosition, in: parentView)
        
        XCTAssertNotNil(section)
        XCTAssertEqual(section.yPosition, yPosition)
        XCTAssertEqual(section.height, VerticalTableLayout.calculateTableHeight(for: 7))
    }
    
    func testCreateVirtualSection() {
        let yPosition: CGFloat = 200
        let section = layoutManager.createVirtualSection(yPosition: yPosition, in: parentView)
        
        XCTAssertNotNil(section)
        XCTAssertEqual(section.yPosition, yPosition)
        XCTAssertEqual(section.height, VerticalTableLayout.calculateTableHeight(for: 7))
    }
    
    func testCreateSwapSection() {
        let yPosition: CGFloat = 300
        let section = layoutManager.createSwapSection(yPosition: yPosition, in: parentView)
        
        XCTAssertNotNil(section)
        XCTAssertEqual(section.yPosition, yPosition)
        XCTAssertEqual(section.height, VerticalTableLayout.calculateTableHeight(for: 7))
    }
    
    func testCreateProcessSection() {
        let yPosition: CGFloat = 400
        let section = layoutManager.createProcessSection(yPosition: yPosition, in: parentView)
        
        XCTAssertNotNil(section)
        XCTAssertEqual(section.yPosition, yPosition)
        XCTAssertEqual(section.height, VerticalTableLayout.processTableHeight)
    }
    
    func testSectionPositioning() {
        let memoryY = layoutManager.calculateWindowHeight() - VerticalTableLayout.topMargin - VerticalTableLayout.calculateTableHeight(for: 7)
        let virtualY = memoryY - VerticalTableLayout.sectionSpacing - VerticalTableLayout.calculateTableHeight(for: 7)
        let swapY = virtualY - VerticalTableLayout.sectionSpacing - VerticalTableLayout.calculateTableHeight(for: 7)
        let processY = swapY - VerticalTableLayout.tableProcessSpacing - VerticalTableLayout.processTableHeight
        
        let memorySection = layoutManager.createMemorySection(yPosition: memoryY, in: parentView)
        let virtualSection = layoutManager.createVirtualSection(yPosition: virtualY, in: parentView)
        let swapSection = layoutManager.createSwapSection(yPosition: swapY, in: parentView)
        let processSection = layoutManager.createProcessSection(yPosition: processY, in: parentView)
        
        XCTAssertEqual(memorySection.yPosition, memoryY)
        XCTAssertEqual(virtualSection.yPosition, virtualY)
        XCTAssertEqual(swapSection.yPosition, swapY)
        XCTAssertEqual(processSection.yPosition, processY)
    }
}