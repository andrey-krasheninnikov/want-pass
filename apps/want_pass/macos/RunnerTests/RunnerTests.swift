import Cocoa
import FlutterMacOS
import XCTest

class RunnerTests: XCTestCase {

  func testClipboardExpiryClearsOnlyTheOriginalWrite() {
    let board = NSPasteboard.withUniqueName()
    defer { board.releaseGlobally() }
    let clipboard = OwnedPasteboard(board)
    let fixture = "synthetic clipboard fixture"
    XCTAssertTrue(clipboard.write(fixture))
    board.clearContents()
    XCTAssertTrue(board.setString(fixture, forType: .string))
    clipboard.clear(matching: fixture)
    XCTAssertEqual(board.string(forType: .string), fixture)
    XCTAssertTrue(clipboard.write(fixture))
    clipboard.clear(matching: "different synthetic value")
    XCTAssertEqual(board.string(forType: .string), fixture)
    clipboard.clear(matching: fixture)
    XCTAssertNil(board.string(forType: .string))
  }

}
