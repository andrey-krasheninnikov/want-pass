import Darwin
import Foundation
import MachO

enum ClientFailure: String, Error {
  case installation = "Use the helper inside the signed Want Pass application."
  case unavailable = "Open and unlock the matching Want Pass application."
  case identity = "The running Want Pass application could not be verified."
  case rejected = "The application denied the request."
}

struct Connection {
  let app: URL, id: String, root: URL
  init() throws {
    var count: UInt32 = 0
    _ = _NSGetExecutablePath(nil, &count)
    var buffer = [CChar](repeating: 0, count: Int(count))
    guard _NSGetExecutablePath(&buffer, &count) == 0 else { throw Wire.error }
    let path = URL(fileURLWithPath: String(cString: buffer)).resolvingSymlinksInPath()
      .standardizedFileURL
    app = path.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    guard let bundle = Bundle(url: app), let identifier = bundle.bundleIdentifier,
      ["foundation.want.pass", "foundation.want.pass.dev"].contains(identifier),
      path == app.appendingPathComponent("Contents/Helpers/wpass")
    else { throw ClientFailure.installation }
    id = identifier
    root = try Wire.directory(id)
    do { try Wire.checkDirectory(root, create: false) } catch { throw ClientFailure.unavailable }
  }

  func request(_ action: String, _ body: [String: Any]) throws -> Any {
    let fd = socket(AF_UNIX, SOCK_STREAM, 0)
    guard fd >= 0 else { throw Wire.error }
    defer { close(fd) }
    try Wire.configure(fd)
    guard
      try Wire.withAddress(root.appendingPathComponent("cli").path, { connect(fd, $0, $1) }) == 0
    else { throw ClientFailure.unavailable }
    do { try Wire.verifyPeer(fd, expected: app, identifier: id) } catch {
      throw ClientFailure.identity
    }
    try Wire.writePacket(fd, Wire.bytes(["action": action, "body": body]))
    let result = try Wire.json(Wire.readPacket(fd))
    guard result["ok"] as? Bool == true, let value = result["result"] else {
      throw ClientFailure.rejected
    }
    return value
  }
}

func confirmAlias(_ previous: String, _ next: String) -> Bool {
  guard isatty(STDIN_FILENO) == 1 else { return false }
  for line in previous.split(separator: "\n") { print("- " + line) }
  for line in next.split(separator: "\n") { print("+ " + line) }
  print("Apply these lines to ~/.ssh/config? [yes/no]", terminator: " ")
  fflush(stdout)
  return readLine() == "yes"
}

func userSSHConfig() throws -> URL {
  guard let home = getpwuid(getuid())?.pointee.pw_dir else { throw Wire.error }
  return URL(fileURLWithPath: String(cString: home)).appendingPathComponent(".ssh/config")
}

func run(_ args: [String]) throws {
  guard let command = args.first else { throw Wire.error }
  if ["--help", "-h", "help"].contains(command) {
    print(
      "wpass authorize search|store|ssh TARGET\nwpass search BINDING [QUERY]\nwpass store BINDING < account.json\nwpass ssh PROFILE\nwpass public-key PROFILE\nwpass alias install|remove PROFILE"
    )
    return
  }
  let client = try Connection()
  if command == "alias" && args.count == 3 && args[1] == "remove" {
    try explicitAlias(
      profile: nil, selector: args[2], root: client.root, config: try userSSHConfig(),
      approve: confirmAlias)
    return
  }
  switch command {
  case "authorize":
    guard args.count == 3, ["search", "store", "ssh"].contains(args[1]) else { throw Wire.error }
    _ = try client.request("authorize", ["operation": args[1], "target": args[2]])
    print("Authorized.")
  case "search":
    guard (2...3).contains(args.count) else { throw Wire.error }
    let result = try client.request(
      "search", ["target": args[1], "query": args.count == 3 ? args[2] : ""])
    guard let list = result as? [[String: String]],
      list.allSatisfy({ Set($0.keys) == ["name", "service"] })
    else { throw Wire.error }
    try FileHandle.standardOutput.write(
      contentsOf: JSONSerialization.data(withJSONObject: list) + Data([10]))
  case "store":
    guard args.count == 2, isatty(STDIN_FILENO) == 0 else { throw Wire.error }
    var bytes = Data()
    while bytes.count <= 65536 {
      guard let chunk = try FileHandle.standardInput.read(upToCount: 65537 - bytes.count),
        !chunk.isEmpty
      else { break }
      bytes.append(chunk)
    }
    let values = try Wire.json(bytes)
    guard Set(values.keys) == ["name", "login", "password"],
      values.values.allSatisfy({ $0 is String })
    else { throw Wire.error }
    _ = try client.request("store", ["target": args[1], "entry": values])
    print("Stored.")
  case "public-key":
    guard args.count == 2,
      let value = try client.request("public-key", ["target": args[1]]) as? String,
      value.hasPrefix("ssh-ed25519 "), !value.contains(where: \.isNewline)
    else { throw Wire.error }
    print(value)
  case "ssh", "alias":
    let alias = command == "alias"
    guard
      (alias && args.count == 3 && ["install", "remove"].contains(args[1]))
        || (!alias && args.count == 2)
    else { throw Wire.error }
    let profile = try Profile(client.request("ssh", ["target": args.last!]))
    if alias {
      try explicitAlias(
        profile: profile, selector: profile.id, root: client.root, config: try userSSHConfig(),
        approve: confirmAlias)
    } else {
      guard isatty(STDIN_FILENO) == 1 else { throw Wire.error }
      try profile.writeHostKey(in: client.root)
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")
      process.arguments =
        ["-F", "/dev/null"] + profile.options(client.root).flatMap { ["-o", $0] } + [
          "-p", String(profile.port), "-l", profile.user, "--", profile.host,
        ]
      process.environment = [
        "PATH": "/usr/bin:/bin", "TERM": ProcessInfo.processInfo.environment["TERM"] ?? "xterm",
      ]
      process.standardInput = FileHandle.standardInput
      process.standardOutput = FileHandle.standardOutput
      process.standardError = FileHandle.standardError
      try process.run()
      process.waitUntilExit()
      exit(process.terminationStatus)
    }
  default: throw Wire.error
  }
}

do { try run(Array(CommandLine.arguments.dropFirst())) } catch let issue as ClientFailure {
  FileHandle.standardError.write(Data((issue.rawValue + "\n").utf8))
  exit(1)
} catch {
  FileHandle.standardError.write(Data("Request unavailable or denied. Use wpass --help.\n".utf8))
  exit(1)
}
