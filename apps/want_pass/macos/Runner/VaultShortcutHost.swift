import Carbon.HIToolbox
import Cocoa
import FlutterMacOS
import Security

private struct ShortcutChord {
  let id: String
  let label: String
  let key: UInt32
  let modifiers: UInt32
  static let choices: [ShortcutChord] = {
    let keys = [
      ("space", "Space", kVK_Space), ("n", "N", kVK_ANSI_N), ("k", "K", kVK_ANSI_K),
      ("j", "J", kVK_ANSI_J), ("p", "P", kVK_ANSI_P),
    ]
    let modifiers = [
      ("co", "⌃⌥", controlKey | optionKey), ("cs", "⌘⇧", cmdKey | shiftKey),
      ("csoption", "⌘⌥", cmdKey | optionKey),
    ]
    return modifiers.flatMap { id, label, flags in
      keys.map { key, title, code in
        ShortcutChord(
          id: "\(id)-\(key)", label: "\(label)\(title)", key: UInt32(code), modifiers: UInt32(flags)
        )
      }
    }
  }()
}

private final class ShortcutPanel: NSPanel {
  var escape: (() -> Void)?
  override var canBecomeKey: Bool { true }
  override func cancelOperation(_ sender: Any?) { escape?() }
}

final class VaultShortcutHost: NSObject, NSSearchFieldDelegate, NSWindowDelegate {
  private static let signature: OSType = 0x5750_5353
  private let channel: FlutterMethodChannel
  private weak var mainWindow: NSWindow?
  private var handler: EventHandlerRef?
  private var registered = [UInt32: EventHotKeyRef]()
  private var errors = [String: String]()
  private var configured: [String: String]
  private let rank = ShortcutUsage()
  private var unlocked = false, russian = false
  private var previousApplication: NSRunningApplication?
  private weak var previousWindow: NSWindow?
  private var panel: ShortcutPanel?
  private var search: NSSearchField?
  private var list: NSStackView?
  private var generation = 0, cursor = 0
  private var choices = [(id: String, title: String)]()
  private var selected: String?
  private var request: DispatchWorkItem?
  private var pendingCopy = false

  init(window: NSWindow, messenger: FlutterBinaryMessenger) {
    mainWindow = window
    channel = FlutterMethodChannel(name: "want_pass/shortcuts", binaryMessenger: messenger)
    let dev = Bundle.main.bundleIdentifier?.hasSuffix(".dev") == true
    let prefs = UserDefaults.standard
    configured = [
      "search": prefs.string(forKey: "quick.search") ?? (dev ? "co-j" : "co-space"),
      "create": prefs.string(forKey: "quick.create") ?? (dev ? "co-k" : "co-n"),
    ]
    super.init()
    var event = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    let installed = InstallEventHandler(
      GetApplicationEventTarget(),
      { _, event, pointer in
        guard let event = event, let pointer = pointer else { return OSStatus(eventNotHandledErr) }
        var hot = EventHotKeyID()
        guard
          GetEventParameter(
            event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil,
            MemoryLayout<EventHotKeyID>.size, nil, &hot) == noErr,
          hot.signature == VaultShortcutHost.signature
        else { return OSStatus(eventNotHandledErr) }
        let host = Unmanaged<VaultShortcutHost>.fromOpaque(pointer).takeUnretainedValue()
        if hot.id == 1 { host.openSearch() }
        if hot.id == 2 { host.openMain("create") }
        return noErr
      }, 1, &event, Unmanaged.passUnretained(self).toOpaque(), &handler)
    for (name, id) in [("search", UInt32(1)), ("create", UInt32(2))] {
      do {
        guard installed == noErr else { throw RegistrationError.denied }
        try register(name: name, id: id, choice: configured[name] ?? "off")
      } catch { errors[name] = (error as? RegistrationError)?.rawValue ?? "denied" }
    }
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "state":
        self.russian = args["russian"] as? Bool == true
        let was = self.unlocked
        self.unlocked = args["unlocked"] as? Bool == true
        if was && !self.unlocked {
          self.dismiss(restore: true)
          self.rank.dropMemory()
        }
        result(true)
      case "used":
        if self.unlocked, let id = call.arguments as? String, id.utf8.count == 32,
          id.allSatisfy({ $0.isHexDigit })
        {
          self.rank.used(id)
        }
        result(nil)
      case "showConfirmation":
        if self.pendingCopy, let panel = self.panel {
          panel.orderOut(nil)
          NSApp.activate(ignoringOtherApps: true)
          self.mainWindow?.makeKeyAndOrderFront(nil)
        }
        result(nil)
      case "configuration": result(self.configuration())
      case "change":
        guard let name = args["name"] as? String, let choice = args["chord"] as? String,
          let id = ["search": UInt32(1), "create": UInt32(2)][name]
        else {
          result(nil)
          return
        }
        do {
          guard self.handler != nil else { throw RegistrationError.denied }
          if self.configured[name] != choice || self.registered[id] == nil {
            try self.register(name: name, id: id, choice: choice)
          }
          self.configured[name] = choice
          UserDefaults.standard.set(choice, forKey: "quick." + name)
          self.errors.removeValue(forKey: name)
        } catch { self.errors[name] = (error as? RegistrationError)?.rawValue ?? "denied" }
        result(self.configuration())
      default: result(FlutterMethodNotImplemented)
      }
    }
  }
  deinit {
    request?.cancel()
    registered.values.forEach { UnregisterEventHotKey($0) }
    if let handler { RemoveEventHandler(handler) }
  }

  private enum RegistrationError: String, Error { case conflict, denied }
  private func register(name: String, id: UInt32, choice: String) throws {
    if choice == "off" {
      if let ref = registered.removeValue(forKey: id) { UnregisterEventHotKey(ref) }
      return
    }
    guard let chord = ShortcutChord.choices.first(where: { $0.id == choice }) else {
      throw RegistrationError.denied
    }
    if configured[name == "search" ? "create" : "search"] == choice {
      throw RegistrationError.conflict
    }
    var next: EventHotKeyRef?
    let status = RegisterEventHotKey(
      chord.key, chord.modifiers, EventHotKeyID(signature: Self.signature, id: id),
      GetApplicationEventTarget(), 0, &next)
    guard status == noErr, let next else {
      throw status == OSStatus(eventHotKeyExistsErr)
        ? RegistrationError.conflict : RegistrationError.denied
    }
    if let ref = registered[id] { UnregisterEventHotKey(ref) }
    registered[id] = next
  }
  private func configuration() -> [String: Any] {
    [
      "selected": configured, "errors": errors,
      "options": ShortcutChord.choices.map { ["id": $0.id, "label": $0.label] },
    ]
  }
  private func label(_ en: String, _ ru: String) -> String { russian ? ru : en }
  private func openMain(_ action: String, card: String? = nil) {
    dismiss(restore: false)
    NSApp.activate(ignoringOtherApps: true)
    mainWindow?.deminiaturize(nil)
    mainWindow?.makeKeyAndOrderFront(nil)
    channel.invokeMethod("navigate", arguments: ["action": action, "id": card ?? ""])
  }
  private func openSearch() {
    if panel != nil {
      dismiss(restore: true)
      return
    }
    previousApplication = NSWorkspace.shared.frontmostApplication
    previousWindow = NSApp.keyWindow
    let point = NSEvent.mouseLocation
    guard
      let frame = (NSScreen.screens.first(where: { $0.frame.contains(point) }) ?? NSScreen.main)?
        .visibleFrame
    else { return }
    let width = min(420, frame.width)
    let height = min(350, frame.height)
    let origin = NSPoint(
      x: min(max(point.x + 8, frame.minX), frame.maxX - width),
      y: min(max(point.y - height - 8, frame.minY), frame.maxY - height))
    let rect = NSRect(origin: origin, size: NSSize(width: width, height: height))
    let surface = ShortcutPanel(
      contentRect: rect, styleMask: [.titled, .fullSizeContentView], backing: .buffered,
      defer: false)
    surface.title = label("Quick search", "Быстрый поиск")
    surface.titleVisibility = .hidden
    surface.titlebarAppearsTransparent = true
    surface.isFloatingPanel = true
    surface.level = .floating
    surface.hidesOnDeactivate = false
    surface.isReleasedWhenClosed = false
    surface.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
    surface.escape = { [weak self] in self?.dismiss(restore: true) }
    surface.delegate = self
    let root = NSVisualEffectView()
    root.material = .popover
    root.state = .active
    let column = NSStackView()
    column.orientation = .vertical
    column.alignment = .leading
    column.spacing = 7
    column.translatesAutoresizingMaskIntoConstraints = false
    root.addSubview(column)
    NSLayoutConstraint.activate([
      column.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 14),
      column.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -14),
      column.topAnchor.constraint(equalTo: root.topAnchor, constant: 14),
      column.bottomAnchor.constraint(lessThanOrEqualTo: root.bottomAnchor, constant: -8),
    ])
    surface.contentView = root
    surface.setFrame(rect, display: true)
    panel = surface
    list = column
    selected = nil
    cursor = 0
    let field = NSSearchField()
    field.font = .systemFont(ofSize: 17)
    field.delegate = self
    field.placeholderString = label("Search secrets", "Поиск секретов")
    field.setAccessibilityLabel(field.placeholderString)
    field.sendsSearchStringImmediately = true
    column.addArrangedSubview(field)
    field.widthAnchor.constraint(equalTo: column.widthAnchor).isActive = true
    search = field
    NSApp.activate(ignoringOtherApps: true)
    surface.makeKeyAndOrderFront(nil)
    surface.makeFirstResponder(field)
    query()
  }
  private func dismiss(restore: Bool) {
    guard let surface = panel else { return }
    generation += 1
    request?.cancel()
    pendingCopy = false
    let previous = previousApplication
    let window = previousWindow
    previousApplication = nil
    previousWindow = nil
    panel = nil
    search?.stringValue = ""
    search = nil
    list = nil
    choices.removeAll()
    selected = nil
    surface.delegate = nil
    surface.orderOut(nil)
    surface.close()
    if restore, let previous,
      previous.processIdentifier != ProcessInfo.processInfo.processIdentifier
    {
      previous.activate(options: [])
    } else if restore {
      window?.makeKeyAndOrderFront(nil)
    }
  }
  func windowDidResignKey(_ notification: Notification) {
    if panel != nil && !pendingCopy { dismiss(restore: false) }
  }
  func controlTextDidChange(_ note: Notification) {
    selected = nil
    cursor = 0
    query()
  }
  func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
    switch selector {
    case #selector(NSResponder.cancelOperation(_:)): dismiss(restore: true)
    case #selector(NSResponder.moveDown(_:)):
      cursor = min(cursor + 1, max(0, choices.count - 1))
      render()
    case #selector(NSResponder.moveUp(_:)):
      cursor = max(0, cursor - 1)
      render()
    case #selector(NSResponder.insertNewline(_:)): activate(cursor)
    default: return false
    }
    return true
  }
  private func query() {
    generation += 1
    let ticket = generation
    request?.cancel()
    choices = []
    render()
    guard let field = search else { return }
    if !unlocked {
      choices = [("unlock", label("Unlock vault", "Разблокировать сейф"))]
      render()
      return
    }
    let text = field.stringValue
    let pending = DispatchWorkItem { [weak self] in
      guard let self, self.panel != nil, self.generation == ticket, self.unlocked else { return }
      self.channel.invokeMethod("query", arguments: ["text": text, "usage": self.rank.entries()]) {
        [weak self] result in
        guard let self, self.panel != nil, self.generation == ticket, self.unlocked else { return }
        let entries = result as? [[String: String]] ?? []
        self.choices = entries.prefix(5).compactMap { row in
          guard let id = row["id"], let name = row["name"] else { return nil }
          return (id, name)
        }
        self.cursor = 0
        self.render()
      }
    }
    request = pending
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: pending)
  }
  private func render() {
    guard let list else { return }
    for view in list.arrangedSubviews.dropFirst() {
      list.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
    if choices.isEmpty {
      let message = NSTextField(labelWithString: label("No results", "Ничего не найдено"))
      message.textColor = .secondaryLabelColor
      list.addArrangedSubview(message)
      return
    }
    let scroll = NSScrollView()
    scroll.hasVerticalScroller = true
    scroll.drawsBackground = false
    let rows = NSStackView()
    rows.orientation = .vertical
    rows.alignment = .leading
    rows.spacing = 3
    scroll.documentView = rows
    list.addArrangedSubview(scroll)
    scroll.widthAnchor.constraint(equalTo: list.widthAnchor).isActive = true
    scroll.heightAnchor.constraint(equalToConstant: min(258, CGFloat(choices.count) * 37))
      .isActive = true
    rows.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      rows.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor),
      rows.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
      rows.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor),
    ])
    for (i, entry) in choices.enumerated() {
      let button = NSButton(title: entry.title, target: self, action: #selector(tapped(_:)))
      button.tag = i
      button.bezelStyle = .regularSquare
      button.isBordered = i == cursor
      button.alignment = .left
      button.lineBreakMode = .byTruncatingTail
      rows.addArrangedSubview(button)
      button.widthAnchor.constraint(equalTo: rows.widthAnchor).isActive = true
      button.heightAnchor.constraint(equalToConstant: 33).isActive = true
      if i == cursor {
        DispatchQueue.main.async { [weak button] in
          guard let button else { return }
          button.scrollToVisible(button.bounds)
        }
      }
    }
  }
  @objc private func tapped(_ sender: NSButton) { activate(sender.tag) }
  private func activate(_ index: Int) {
    guard choices.indices.contains(index) else { return }
    let option = choices[index].id
    if !unlocked {
      if option == "unlock" { openMain("unlock") }
      return
    }
    if let card = selected {
      if option == "settings" {
        openMain("settings", card: card)
        return
      }
      if option == "back" {
        selected = nil
        query()
        return
      }
      guard !pendingCopy, let surface = panel else { return }
      let ticket = generation
      pendingCopy = true
      let prior = previousApplication
      channel.invokeMethod("copy", arguments: ["id": card, "action": option]) {
        [weak self] result in
        guard let self, self.panel != nil, self.generation == ticket else { return }
        self.pendingCopy = false
        if result as? Bool == true {
          self.dismiss(restore: true)
        } else if self.unlocked {
          self.previousApplication = prior
          surface.makeKeyAndOrderFront(nil)
          surface.makeFirstResponder(self.search)
        } else {
          self.dismiss(restore: false)
        }
      }
      return
    }
    generation += 1
    let ticket = generation
    selected = option
    choices = []
    cursor = 0
    render()
    channel.invokeMethod("actions", arguments: option) { [weak self] result in
      guard let self, self.panel != nil, self.generation == ticket, self.unlocked else { return }
      self.choices = (result as? [[String: String]] ?? []).compactMap { row in
        guard let id = row["id"], let title = row["title"] else { return nil }
        return (id, title)
      }
      self.choices.append(("back", self.label("Back", "Назад")))
      self.render()
    }
  }
}

private final class ShortcutUsage {
  private var cache: [String: [Int]]?
  private var query: [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: (Bundle.main.bundleIdentifier ?? "foundation.want.pass")
        + ".quick-usage", kSecAttrAccount as String: "local",
    ]
  }
  func dropMemory() { cache = nil }
  func entries() -> [String: [Int]] {
    if let cache { return cache }
    var lookup = query
    lookup[kSecReturnData as String] = true
    lookup[kSecMatchLimit as String] = kSecMatchLimitOne
    var reference: CFTypeRef?
    let data =
      SecItemCopyMatching(lookup as CFDictionary, &reference) == errSecSuccess
      ? reference as? Data : nil
    cache = data.flatMap { try? JSONDecoder().decode([String: [Int]].self, from: $0) } ?? [:]
    return cache ?? [:]
  }
  func used(_ id: String) {
    var values = entries()
    if values[id] == nil && values.count >= 4096,
      let oldest = values.min(by: { ($0.value.last ?? 0) < ($1.value.last ?? 0) })?.key
    {
      values.removeValue(forKey: oldest)
    }
    values[id] = [min(1_000_000, (values[id]?.first ?? 0) + 1), Int(Date().timeIntervalSince1970)]
    cache = values
    guard let data = try? JSONEncoder().encode(values) else { return }
    let update = [kSecValueData as String: data]
    if SecItemUpdate(query as CFDictionary, update as CFDictionary) == errSecItemNotFound {
      var item = query
      item[kSecValueData as String] = data
      item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      SecItemAdd(item as CFDictionary, nil)
    }
  }
}
