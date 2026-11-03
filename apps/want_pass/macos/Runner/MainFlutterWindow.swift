import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var splashView: NSView?
  private var vaultLockEvents: VaultLockEvents?
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
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
        if call.method == "ready" { result(true) }
        else { result(FlutterMethodNotImplemented) }
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
