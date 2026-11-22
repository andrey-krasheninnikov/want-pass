import Cocoa
import Darwin
import FlutterMacOS

private typealias Wire = LocalToolsTransport
private struct Listener {
  let source: DispatchSourceRead
  let id: String?
}
private final class ReplyBox {
  let ready = DispatchSemaphore(value: 0)
  var value: Any?
}

final class LocalToolsServer {
  private let channel: FlutterMethodChannel
  private let identifier: String
  private let queue = DispatchQueue(label: "foundation.want.pass.local-transport")
  private let slots = DispatchSemaphore(value: 6)
  private var listeners: [String: Listener] = [:]
  private var requests: [String: Int32] = [:]
  private var currentSession = UUID()

  init(messenger: FlutterBinaryMessenger) {
    identifier = Bundle.main.bundleIdentifier ?? ""
    channel = FlutterMethodChannel(name: "want_pass/local_tools", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, reply in
      guard let self = self else {
        reply(false)
        return
      }
      if call.method == "active", let token = call.arguments as? String {
        reply(
          self.queue.sync {
            guard let fd = self.requests[token] else { return false }
            var byte: UInt8 = 0
            let n = recv(fd, &byte, 1, MSG_PEEK | MSG_DONTWAIT)
            return n > 0 || (n < 0 && (errno == EWOULDBLOCK || errno == EAGAIN))
          })
        return
      }
      guard call.method == "listen" || call.method == "stop" else {
        reply(FlutterMethodNotImplemented)
        return
      }
      let profiles = call.arguments as? [String] ?? []
      self.queue.async {
        do {
          if call.method == "stop" { self.reset() } else { try self.listen(profiles) }
          DispatchQueue.main.async { reply(true) }
        } catch {
          self.reset()
          DispatchQueue.main.async { reply(false) }
        }
      }
    }
  }

  private func reset() {
    currentSession = UUID()
    listeners.values.forEach { $0.source.cancel() }
    listeners.removeAll()
    for fd in requests.values { _ = shutdown(fd, SHUT_RDWR) }
    requests.removeAll()
  }

  private func listen(_ profiles: [String]) throws {
    let root = try Wire.directory(identifier)
    try Wire.checkDirectory(root, create: true)
    guard profiles.count <= 128,
      profiles.allSatisfy({
        $0.count == 32 && $0.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
      })
    else { throw Wire.error }
    var desired: [String: String] = ["cli": ""]
    for id in profiles { desired["s-" + String(id.prefix(16))] = id }
    guard desired.count == Set(profiles).count + 1 else { throw Wire.error }
    for name in Array(listeners.keys) where desired[name] == nil {
      listeners.removeValue(forKey: name)?.source.cancel()
    }
    for (name, id) in desired where listeners[name] == nil {
      let path = root.appendingPathComponent(name).path
      let fd = socket(AF_UNIX, SOCK_STREAM, 0)
      guard fd >= 0 else { throw Wire.error }
      do {
        try Wire.configure(fd)
        guard fcntl(fd, F_SETFL, O_NONBLOCK) == 0 else { throw Wire.error }
        var old = stat()
        if lstat(path, &old) == 0 {
          guard old.st_uid == getuid(), (old.st_mode & S_IFMT) == S_IFSOCK else { throw Wire.error }
          let check = socket(AF_UNIX, SOCK_STREAM, 0)
          guard check >= 0 else { throw Wire.error }
          let absent = try Wire.withAddress(path) {
            Darwin.connect(check, $0, $1) < 0 && errno == ECONNREFUSED
          }
          close(check)
          var now = stat()
          guard absent, lstat(path, &now) == 0, now.st_ino == old.st_ino, unlink(path) == 0 else {
            throw Wire.error
          }
        }
        guard try Wire.withAddress(path, { bind(fd, $0, $1) }) == 0, chmod(path, 0o600) == 0,
          Darwin.listen(fd, 8) == 0
        else { throw Wire.error }
        var own = stat()
        guard lstat(path, &own) == 0 else { throw Wire.error }
        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
        let profile = id.isEmpty ? nil : id
        source.setEventHandler { [weak self] in
          guard let self = self else { return }
          let client = accept(fd, nil, nil)
          if client < 0 { return }
          let session = self.currentSession
          if self.slots.wait(timeout: .now()) != .success {
            close(client)
            return
          }
          DispatchQueue.global(qos: .userInitiated).async {
            defer {
              close(client)
              self.slots.signal()
            }
            do {
              try Wire.configure(client)
              let url =
                profile == nil
                ? Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/wpass")
                : URL(fileURLWithPath: "/usr/bin/ssh")
              try Wire.verifyPeer(
                client, expected: url,
                identifier: profile == nil ? self.identifier + ".wpass" : "com.apple.ssh")
              if let profile = profile {
                try self.ssh(client, profile: profile, session: session)
              } else {
                try self.cli(client, session: session)
              }
            } catch {}
          }
        }
        let inode = own.st_ino
        source.setCancelHandler {
          close(fd)
          var now = stat()
          if lstat(path, &now) == 0 && now.st_ino == inode { _ = unlink(path) }
        }
        listeners[name] = Listener(source: source, id: profile)
        source.resume()
      } catch {
        close(fd)
        throw error
      }
    }
  }

  private func dispatch(_ action: String, _ body: [String: Any], _ fd: Int32, _ session: UUID)
    throws -> Any
  {
    let token = UUID().uuidString
    guard
      queue.sync(execute: {
        if currentSession != session { return false }
        requests[token] = fd
        return true
      })
    else { throw Wire.error }
    defer { _ = queue.sync { requests.removeValue(forKey: token) } }
    let box = ReplyBox()
    DispatchQueue.main.async { [weak self] in
      self?.channel.invokeMethod(
        "request", arguments: ["action": action, "body": body, "token": token]
      ) { response in
        box.value = response
        box.ready.signal()
      }
    }
    guard box.ready.wait(timeout: .now() + 65) == .success,
      queue.sync(execute: { currentSession == session }),
      let value = box.value, !(value is FlutterError), !(value is NSNull)
    else { throw Wire.error }
    return value
  }

  private func cli(_ fd: Int32, session: UUID) throws {
    do {
      let request = try Wire.json(Wire.readPacket(fd))
      guard let action = request["action"] as? String,
        ["authorize", "search", "store", "ssh", "public-key"].contains(action),
        let body = request["body"] as? [String: Any], Set(request.keys) == ["action", "body"]
      else { throw Wire.error }
      let result = try dispatch(action, body, fd, session)
      try Wire.writePacket(fd, Wire.bytes(["ok": true, "result": result]))
    } catch { try Wire.writePacket(fd, Wire.bytes(["ok": false])) }
  }

  private func ssh(_ fd: Int32, profile: String, session: UUID) throws {
    var binding: Data?
    for _ in 0..<32 {
      let packet = try Wire.readPacket(fd)
      var body = Data(packet.dropFirst())
      func field() throws -> Data {
        guard body.count >= 4 else { throw Wire.error }
        let n = body.prefix(4).reduce(0) { $0 << 8 | Int($1) }
        guard n <= body.count - 4 else { throw Wire.error }
        let value = Data(body.dropFirst(4).prefix(n))
        body = Data(body.dropFirst(4 + n))
        return value
      }
      do {
        switch packet.first {
        case 27:
          guard binding == nil, try field() == Data("session-bind@openssh.com".utf8),
            body.count <= 32768, body.last == 0
          else { throw Wire.error }
          binding = body
          try Wire.writePacket(fd, Data([6]))
        case 11:
          guard body.isEmpty,
            let blob = try dispatch("identity", ["profile": profile], fd, session) as? String,
            let key = Data(base64Encoded: blob)
          else { throw Wire.error }
          try Wire.writePacket(fd, Data([12, 0, 0, 0, 1]) + Wire.string(key) + Wire.string(Data()))
        case 13:
          let key = try field()
          let data = try field()
          guard let binding = binding, body == Data([0, 0, 0, 0]),
            let result = try dispatch(
              "sign",
              [
                "profile": profile, "binding": binding.base64EncodedString(),
                "key": key.base64EncodedString(), "data": data.base64EncodedString(),
              ], fd, session) as? String,
            let signature = Data(base64Encoded: result)
          else { throw Wire.error }
          try Wire.writePacket(fd, Data([14]) + Wire.string(signature))
        default: throw Wire.error
        }
      } catch { try Wire.writePacket(fd, Data([5])) }
    }
  }
}
