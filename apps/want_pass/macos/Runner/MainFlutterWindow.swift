import Cocoa
import FlutterMacOS
import LocalAuthentication
import ImageIO
import Vision

class MainFlutterWindow: NSWindow {
  private var shortcutHost: VaultShortcutHost?
  private let ownedPasteboard = OwnedPasteboard(.general)
  private var splashView: NSView?
  private var vaultLockEvents: VaultLockEvents?
  private var localTools: LocalToolsServer?
  private var backupDirectory: VaultBackupDirectory?
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    FlutterMethodChannel(name: "want_pass/clipboard", binaryMessenger: flutterViewController.engine.binaryMessenger)
      .setMethodCallHandler { [weak self] call, result in
        guard let owner = self?.ownedPasteboard, let text = call.arguments as? String else {
          result(FlutterError(code: "clipboard_unavailable", message: nil, details: nil)); return
        }
        switch call.method {
        case "write":
          if owner.write(text) { result(nil) }
          else { result(FlutterError(code: "clipboard_unavailable", message: nil, details: nil)) }
        case "clearOwned": owner.clear(matching: text); result(nil)
        default: result(FlutterMethodNotImplemented)
        }
      }
    backupDirectory = VaultBackupDirectory(window: self, messenger: flutterViewController.engine.binaryMessenger)
    installImportQRChannel(flutterViewController.engine.binaryMessenger)
    localTools = LocalToolsServer(messenger: flutterViewController.engine.binaryMessenger)
    shortcutHost = VaultShortcutHost(window: self, messenger: flutterViewController.engine.binaryMessenger)
    vaultLockEvents = VaultLockEvents(messenger: flutterViewController.engine.binaryMessenger)

    let splash = NSView(frame: flutterViewController.view.bounds)
    splash.autoresizingMask = [.width, .height]
    splash.wantsLayer = true
    splash.layer?.backgroundColor = NSColor(named: "SplashBackground")?.cgColor
    let image = NSImageView()
    image.image = NSImage(named: "SplashLogo")
    image.imageScaling = .scaleProportionallyUpOrDown
    image.translatesAutoresizingMaskIntoConstraints = false
    splash.addSubview(image)
    NSLayoutConstraint.activate([
      image.centerXAnchor.constraint(equalTo: splash.centerXAnchor),
      image.centerYAnchor.constraint(equalTo: splash.centerYAnchor),
      image.widthAnchor.constraint(equalToConstant: 160),
      image.heightAnchor.constraint(equalToConstant: 160)
    ])
    flutterViewController.view.addSubview(splash)
    splashView = splash
    FlutterMethodChannel(name: "want_pass/splash", binaryMessenger: flutterViewController.engine.binaryMessenger)
      .setMethodCallHandler { [weak self] call, result in
        guard call.method == "firstFrame" else { result(FlutterMethodNotImplemented); return }
        self?.splashView?.removeFromSuperview()
        self?.splashView = nil
        result(true)
      }

    super.awakeFromNib()
  }
}


private final class VaultBackupDirectory {
  private weak var window: NSWindow?
  private var pending = false
  private var selected: (destination: String, directory: URL)?

  init(window: NSWindow, messenger: FlutterBinaryMessenger) {
    self.window = window
    FlutterMethodChannel(name: "want_pass/backup_directory", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, reply in
        guard let self = self else { reply(nil); return }
        switch call.method {
        case "choose":
          self.choose(reply)
        case "release":
          if let destination = call.arguments as? String, destination == self.selected?.destination {
            self.selected?.directory.stopAccessingSecurityScopedResource()
            self.selected = nil
          }
          reply(nil)
        default: reply(FlutterMethodNotImplemented)
        }
      }
  }

  deinit { selected?.directory.stopAccessingSecurityScopedResource() }

  private func choose(_ reply: @escaping FlutterResult) {
    guard let window = window, !pending, selected == nil else { reply(nil); return }
    pending = true
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.canCreateDirectories = true
    panel.allowsMultipleSelection = false
    panel.beginSheetModal(for: window) { [self] response in
      pending = false
      guard response == .OK, let directory = panel.url else { reply(nil); return }
      let date = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
      let name = "want-pass-\(date)-\(UUID().uuidString.lowercased()).wpassbackup"
      let destination = directory.appendingPathComponent(name, isDirectory: false).path
      selected = (destination, directory)
      reply(destination)
    }
  }
}

private func installImportQRChannel(_ messenger: FlutterBinaryMessenger) {
  let channel = FlutterMethodChannel(name: "want_pass/import_qr", binaryMessenger: messenger)
  channel.setMethodCallHandler { call, result in
    guard call.method == "decode" else { result(FlutterMethodNotImplemented); return }
    guard let input = call.arguments as? FlutterStandardTypedData,
          input.data.count <= 12 * 1024 * 1024 else {
      result(FlutterError(code: "invalid-qr", message: nil, details: nil)); return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let strings: [String]? = autoreleasepool {
        guard let source = CGImageSourceCreateWithData(input.data as CFData, nil),
              CGImageSourceGetCount(source) == 1,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let width = properties[kCGImagePropertyPixelWidth as String] as? Int,
              let height = properties[kCGImagePropertyPixelHeight as String] as? Int,
              width > 0, height > 0, width <= 16384, height <= 16384,
              width * height <= 32_000_000 else { return nil }
        let options: [CFString: Any] = [
          kCGImageSourceCreateThumbnailFromImageAlways: true,
          kCGImageSourceCreateThumbnailWithTransform: true,
          kCGImageSourceThumbnailMaxPixelSize: 4096,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        do {
          try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
          guard let observations = request.results, !observations.isEmpty, observations.count <= 64 else { return nil }
          var values: [String] = []
          for barcode in observations {
            guard let text = barcode.payloadStringValue, text.utf8.count <= 32768 else { return nil }
            values.append(text)
          }
          return values
        } catch { return nil }
      }
      DispatchQueue.main.async {
        if let strings = strings { result(strings) }
        else { result(FlutterError(code: "invalid-qr", message: nil, details: nil)) }
      }
    }
  }
}

private final class VaultLockEvents: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var workspaceObservers: [NSObjectProtocol] = []
  private var screenLockObserver: NSObjectProtocol?

  init(messenger: FlutterBinaryMessenger) {
    super.init()
    FlutterEventChannel(name: "want_pass/vault_lock_events", binaryMessenger: messenger)
      .setStreamHandler(self)
    FlutterMethodChannel(name: "want_pass/vault_lifecycle", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        switch call.method {
        case "ready": result(true)
        case "canUseBiometrics":
          let context = LAContext()
          var error: NSError?
          result(context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && context.biometryType == .touchID)
        case "storageChannel":
          switch Bundle.main.bundleIdentifier {
          case "foundation.want.pass.dev": result("development")
          case "foundation.want.pass": result("production")
          default: result(FlutterError(code: "unknown_bundle", message: nil, details: nil))
          }
        default: result(FlutterMethodNotImplemented)
        }
      }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    let workspace = NSWorkspace.shared.notificationCenter
    for name in [NSWorkspace.willSleepNotification, NSWorkspace.screensDidSleepNotification,
                 NSWorkspace.sessionDidResignActiveNotification] {
      workspaceObservers.append(workspace.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
        self?.sink?("lock")
      })
    }
    // This notification complements documented workspace sleep/session notifications.
    screenLockObserver = DistributedNotificationCenter.default().addObserver(
      forName: NSNotification.Name("com.apple.screenIsLocked"), object: nil, queue: .main
    ) { [weak self] _ in self?.sink?("lock") }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    let workspace = NSWorkspace.shared.notificationCenter
    workspaceObservers.forEach(workspace.removeObserver)
    workspaceObservers.removeAll()
    if let observer = screenLockObserver {
      DistributedNotificationCenter.default().removeObserver(observer)
    }
    screenLockObserver = nil
    sink = nil
    return nil
  }
}
