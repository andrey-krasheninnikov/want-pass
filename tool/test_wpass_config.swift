import Darwin
import Foundation

@main
struct ConfigurationFixture {
  static func main() throws {
    let fm = FileManager.default
    let workspace = fm.temporaryDirectory.appendingPathComponent(
      "want-pass-ssh-test-" + UUID().uuidString)
    try fm.createDirectory(
      at: workspace, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    defer { try? fm.removeItem(at: workspace) }
    let ssh = workspace.appendingPathComponent(".ssh")
    let config = ssh.appendingPathComponent("config")
    let profile = try Profile([
      "id": String(repeating: "a", count: 32), "alias": "fixture", "host": "example.invalid",
      "user": "owner", "port": 22, "host_key": "ssh-ed25519 synthetic",
    ])
    try explicitAlias(profile: profile, selector: profile.id, root: workspace, config: config) {
      _, _ in false
    }
    guard !fm.fileExists(atPath: ssh.path),
      !fm.fileExists(atPath: profile.knownHosts(workspace).path)
    else {
      throw Wire.error
    }
    try fm.createDirectory(
      at: ssh, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    let unrelated = Data("ServerAliveInterval 55\n\nHost other\n  User unchanged\n".utf8)
    try unrelated.write(to: config)
    try explicitAlias(profile: profile, selector: profile.id, root: workspace, config: config) {
      old, new in old.isEmpty && new.contains("Host fixture\n") && new.contains("Host *\n")
    }
    let managed = try Data(contentsOf: config)
    guard managed.suffix(unrelated.count) == unrelated,
      let text = String(data: managed, encoding: .utf8)
    else { throw Wire.error }
    func effectiveOptions(_ alias: String) throws -> String {
      let ssh = Process()
      let output = Pipe()
      ssh.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")
      ssh.arguments = ["-G", "-F", config.path, alias]
      ssh.standardOutput = output
      ssh.standardError = FileHandle.nullDevice
      try ssh.run()
      let bytes = output.fileHandleForReading.readDataToEndOfFile()
      ssh.waitUntilExit()
      guard ssh.terminationStatus == 0, let options = String(data: bytes, encoding: .utf8) else {
        throw Wire.error
      }
      return options
    }
    let own = try effectiveOptions("fixture")
    let other = try effectiveOptions("other")
    guard own.contains("hostname example.invalid\n"), own.contains("user owner\n"),
      own.contains("identityagent " + profile.socket(workspace) + "\n"),
      own.contains("forwardagent no\n"),
      !own.contains("\nproxycommand "),
      other.contains("user unchanged\n"), other.contains("serveraliveinterval 55\n")
    else { throw Wire.error }
    let altered = Data(
      text.replacingOccurrences(
        of: "  Port 22\n", with: "  Port 22\n  HostKeyAlias somebody-else\n"
      ).utf8)
    try altered.write(to: config)
    var rejected = false
    do {
      try explicitAlias(profile: nil, selector: "fixture", root: workspace, config: config) {
        _, _ in true
      }
    } catch { rejected = true }
    guard rejected, try Data(contentsOf: config) == altered else { throw Wire.error }
    try managed.write(to: config)
    try explicitAlias(profile: nil, selector: "fixture", root: workspace, config: config) { _, _ in
      true
    }
    guard try Data(contentsOf: config) == unrelated else { throw Wire.error }
    for hostLine in ["Host \"fixture\"", "Host=fixture", "hOsT = 'FiXtUrE' other"] {
      let occupied = Data((hostLine + "\n  User keep\n").utf8)
      try occupied.write(to: config)
      var prompted = false
      do {
        try explicitAlias(profile: profile, selector: profile.id, root: workspace, config: config) {
          _, _ in
          prompted = true
          return true
        }
      } catch {}
      guard !prompted, try Data(contentsOf: config) == occupied else { throw Wire.error }
    }
    let foreign = workspace.appendingPathComponent("elsewhere")
    try unrelated.write(to: foreign)
    try fm.removeItem(at: config)
    try fm.createSymbolicLink(at: config, withDestinationURL: foreign)
    rejected = false
    do {
      try explicitAlias(profile: profile, selector: profile.id, root: workspace, config: config) {
        _, _ in true
      }
    } catch { rejected = true }
    guard rejected, try Data(contentsOf: foreign) == unrelated else { throw Wire.error }
    print("SSH configuration fixture passed.")
  }
}
