import AppKit
import CryptoKit

final class OwnedPasteboard {
  private let board: NSPasteboard
  private var generation: Int?
  private var marker: NSPasteboard.PasteboardType?
  private var fingerprint: SHA256.Digest?

  init(_ board: NSPasteboard) { self.board = board }

  func write(_ value: String) -> Bool {
    let item = NSPasteboardItem()
    let mark = NSPasteboard.PasteboardType("foundation.want.pass.copy." + UUID().uuidString)
    guard item.setString(value, forType: .string),
          item.setData(Data(), forType: mark),
          item.setData(Data(), forType: NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")) else { return false }
    generation = nil
    fingerprint = nil
    marker = nil
    board.prepareForNewContents(with: .currentHostOnly)
    guard board.writeObjects([item]) else { return false }
    marker = mark
    fingerprint = SHA256.hash(data: Data(value.utf8))
    generation = board.changeCount
    return true
  }

  func clear(matching value: String) {
    guard let count = generation, let mark = marker, fingerprint == SHA256.hash(data: Data(value.utf8)) else { return }
    defer { generation = nil; marker = nil; fingerprint = nil }
    guard board.changeCount == count, board.availableType(from: [mark]) == mark, board.changeCount == count else { return }
    board.clearContents()
  }
}
