import Foundation

@main struct FixtureAlias {
  static func main() throws {
    guard CommandLine.arguments.count == 2 else { throw Wire.error }
    let dir = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    guard dir.lastPathComponent.hasPrefix(".wpass-test-"),
      dir.deletingLastPathComponent().path.hasSuffix("/foundation.want.pass.dev/Data")
    else { throw Wire.error }
    let server = try Wire.json(Data(contentsOf: dir.appendingPathComponent("server.json")))
    let ready = try Wire.json(Data(contentsOf: dir.appendingPathComponent("ready.json")))
    let profile = try Profile([
      "id": ready["id"] as Any, "alias": "acceptance-loopback", "host": "127.0.0.1",
      "port": server["port"] as Any, "user": "fixture", "host_key": server["public_key"] as Any,
    ])
    try explicitAlias(
      profile: profile, selector: profile.id,
      root: dir.deletingLastPathComponent().appendingPathComponent(".wpass"),
      config: dir.appendingPathComponent(".ssh/config")
    ) { _, new in new.contains("Host acceptance-loopback\n") }
  }
}
