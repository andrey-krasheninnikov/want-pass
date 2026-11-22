import Carbon.HIToolbox
import Cocoa
import FlutterMacOS

private final class FixtureMessenger: NSObject, FlutterBinaryMessenger {
  let codec = FlutterStandardMethodCodec.sharedInstance()
  var handler: FlutterBinaryMessageHandler?
  var requests: [String] = []
  func send(onChannel channel: String, message: Data?) {
    send(onChannel: channel, message: message, binaryReply: nil)
  }
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
    guard let message else { return }
    let call = codec.decodeMethodCall(message)
    requests.append(call.method)
    switch call.method {
    case "query":
      callback?(
        codec.encodeSuccessEnvelope(
          (0..<6).map { ["id": String(format: "%032x", $0), "name": "Fixture \($0)"] }))
    case "actions":
      callback?(codec.encodeSuccessEnvelope([["id": "settings", "title": "Settings"]]))
    case "navigate":
      if let args = call.arguments as? [String: String] { requests.append(args["action"] ?? "") }
      callback?(codec.encodeSuccessEnvelope(true))
    default: callback?(codec.encodeSuccessEnvelope(false))
    }
  }
  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?
  ) -> FlutterBinaryMessengerConnection {
    self.handler = handler
    return 1
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) { handler = nil }
  func receive(_ name: String, _ value: Any? = nil) -> Any? {
    var result: Any?
    handler?(codec.encode(FlutterMethodCall(methodName: name, arguments: value))) { data in
      if let data { result = self.codec.decodeEnvelope(data) }
    }
    return result
  }
}

private func expect(_ condition: @autoclosure () -> Bool, _ what: String) throws {
  if !condition() {
    throw NSError(domain: "ShortcutSmoke", code: 1, userInfo: [NSLocalizedDescriptionKey: what])
  }
}
private func spin(_ duration: TimeInterval = 0.18) {
  let until = Date(timeIntervalSinceNow: duration)
  while Date() < until {
    if let event = NSApp.nextEvent(
      matching: .any, until: Date(timeIntervalSinceNow: 0.01), inMode: .default, dequeue: true)
    {
      NSApp.sendEvent(event)
    }
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.002))
  }
}
private func hot(_ id: UInt32) throws {
  var event: EventRef?
  let status = CreateEvent(
    nil, OSType(kEventClassKeyboard), UInt32(kEventHotKeyPressed), GetCurrentEventTime(), 0, &event)
  try expect(status == noErr && event != nil, "Create own Carbon event")
  guard let event else { return }
  defer { ReleaseEvent(event) }
  var hot = EventHotKeyID(signature: 0x5750_5353, id: id)
  try expect(
    SetEventParameter(
      event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
      MemoryLayout<EventHotKeyID>.size, &hot) == noErr, "Encode shortcut")
  try expect(
    SendEventToEventTarget(event, GetApplicationEventTarget()) == noErr,
    "Deliver to fixture process")
  spin()
}
private func descendants(_ view: NSView?) -> [NSView] {
  guard let view else { return [] }
  return [view] + view.subviews.flatMap { descendants($0) }
}

@main private enum ShortcutSmoke {
  static func main() {
    do { try exercise() } catch {
      FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
      exit(1)
    }
  }
  private static func exercise() throws {
    guard let bundle = Bundle.main.bundleIdentifier,
      bundle.hasPrefix("foundation.want.pass.shortcut-smoke.")
    else { throw NSError(domain: "FixtureBundleRequired", code: 1) }
    _ = NSApplication.shared
    NSApp.setActivationPolicy(.accessory)
    NSApp.finishLaunching()
    let defaults = UserDefaults.standard
    defer { defaults.removePersistentDomain(forName: bundle) }
    defaults.set("co-p", forKey: "quick.search")
    defaults.set("csoption-j", forKey: "quick.create")
    let main = NSWindow(
      contentRect: NSRect(x: 100, y: 100, width: 180, height: 100), styleMask: [.titled],
      backing: .buffered, defer: false)
    main.title = "Shortcut fixture"
    main.isReleasedWhenClosed = false
    let prior = NSWorkspace.shared.frontmostApplication
    defer {
      main.orderOut(nil)
      main.close()
      if let prior, prior.processIdentifier != ProcessInfo.processInfo.processIdentifier {
        prior.activate(options: [])
      }
    }
    NSApp.activate(ignoringOtherApps: true)
    main.makeKeyAndOrderFront(nil)
    spin()
    try expect(NSApp.keyWindow === main, "Focus fixture window before dispatch")
    let wire = FixtureMessenger()
    let host = VaultShortcutHost(window: main, messenger: wire)
    defer { withExtendedLifetime(host) {} }
    let configuration = wire.receive("configuration") as? [String: Any]
    try expect(
      (configuration?["errors"] as? [String: String])?.isEmpty == true,
      "Register both fixture shortcuts")
    let conflict = wire.receive("change", ["name": "create", "chord": "co-p"]) as? [String: Any]
    try expect(
      (conflict?["errors"] as? [String: String])?["create"] == "conflict",
      "Reject conflicting shortcut")
    _ = wire.receive("state", ["unlocked": false, "russian": false])
    try hot(1)
    guard let panel = NSApp.keyWindow as? NSPanel else {
      throw NSError(domain: "MissingFixturePanel", code: 1)
    }
    try expect(
      NSScreen.screens.contains { $0.visibleFrame.contains(panel.frame) },
      "Panel within active display")
    try expect(
      descendants(panel.contentView).compactMap { $0 as? NSButton }.contains {
        $0.title == "Unlock vault"
      }, "Locked panel offers unlock")
    try expect(!wire.requests.contains("query"), "No vault search while locked")
    let field = descendants(panel.contentView).compactMap { $0 as? NSSearchField }.first
    try expect(field?.currentEditor() != nil, "Focused search field")
    let escape = NSEvent.keyEvent(
      with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0,
      windowNumber: panel.windowNumber, context: nil, characters: "\u{1b}",
      charactersIgnoringModifiers: "\u{1b}", isARepeat: false, keyCode: 53)!
    panel.sendEvent(escape)
    spin()
    try expect(
      !panel.isVisible && NSApp.keyWindow === main, "Escape closes panel and restores fixture focus"
    )
    _ = wire.receive("state", ["unlocked": true, "russian": false])
    try hot(1)
    guard let unlocked = NSApp.keyWindow as? NSPanel else {
      throw NSError(domain: "MissingSearchSurface", code: 1)
    }
    let labels = descendants(unlocked.contentView).compactMap { $0 as? NSButton }.map(\.title)
      .filter { $0.hasPrefix("Fixture ") }
    try expect(labels.count == 5 && !labels.contains("Fixture 5"), "At most five synthetic results")
    _ = wire.receive("state", ["unlocked": false, "russian": false])
    spin()
    try expect(!unlocked.isVisible, "Lock discards results")
    try hot(2)
    try expect(wire.requests.contains("create"), "Creation hotkey reaches existing navigation")
    print("Shortcut smoke passed on \(NSScreen.screens.count) display(s).")
  }
}
