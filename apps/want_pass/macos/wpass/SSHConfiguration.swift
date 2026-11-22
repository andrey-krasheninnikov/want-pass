import CryptoKit
import Darwin
import Foundation

typealias Wire = LocalToolsTransport

struct Profile {
  let id: String, alias: String, host: String, user: String, port: Int, hostKey: String
  init(_ value: Any) throws {
    guard let p = value as? [String: Any], let id = p["id"] as? String, id.count == 32,
      id.allSatisfy(\.isHexDigit),
      let alias = p["alias"] as? String, let host = p["host"] as? String,
      let user = p["user"] as? String,
      let port = p["port"] as? Int, (1...65535).contains(port), let key = p["host_key"] as? String,
      [alias, host, user].allSatisfy({
        !$0.isEmpty && $0.count <= 253
          && $0.utf8.allSatisfy {
            (48...57).contains($0) || (65...90).contains($0) || (97...122).contains($0)
              || [45, 46, 95].contains($0)
          }
      }),
      key.hasPrefix("ssh-ed25519 "), !key.contains(where: \.isNewline)
    else { throw Wire.error }
    self.id = id
    self.alias = alias
    self.host = host
    self.user = user
    self.port = port
    hostKey = key
  }
  func socket(_ root: URL) -> String {
    root.appendingPathComponent("s-" + String(id.prefix(16))).path
  }
  func knownHosts(_ root: URL) -> URL { root.appendingPathComponent("h-" + id) }

  func writeHostKey(in root: URL) throws {
    let url = knownHosts(root)
    let name = port == 22 ? host : "[\(host)]:\(port)"
    let data = Data("\(name) \(hostKey)\n".utf8)
    var existing = stat()
    if lstat(url.path, &existing) == 0 {
      guard existing.st_uid == getuid(), (existing.st_mode & S_IFMT) == S_IFREG,
        existing.st_nlink == 1
      else { throw Wire.error }
    }
    try data.write(to: url, options: .atomic)
    guard chmod(url.path, 0o600) == 0 else { throw Wire.error }
  }
  func options(_ root: URL) -> [String] {
    let known = knownHosts(root)
    return [
      "IdentityAgent=" + socket(root), "IdentityFile=none", "IdentitiesOnly=no",
      "PreferredAuthentications=publickey", "PasswordAuthentication=no",
      "KbdInteractiveAuthentication=no", "ForwardAgent=no", "StrictHostKeyChecking=yes",
      "UserKnownHostsFile=" + known.path, "GlobalKnownHostsFile=/dev/null", "UpdateHostKeys=no",
      "ControlMaster=no", "ControlPath=none", "PermitLocalCommand=no", "ProxyCommand=none",
      "HostKeyAlgorithms=ssh-ed25519",
    ]
  }
}

private func hostAliases(_ line: Substring) -> [String] {
  var tokens = [String]()
  var token = ""
  var quote: Character?
  var escaped = false
  for char in line {
    if escaped {
      token.append(char)
      escaped = false
      continue
    }
    if char == "\\" {
      escaped = true
      continue
    }
    if let q = quote {
      if char == q { quote = nil } else { token.append(char) }
      continue
    }
    if char == "\"" || char == "'" {
      quote = char
      continue
    }
    if char == "#" { break }
    if char == " " || char == "\t" || char == "=" && tokens.count <= 1 {
      if !token.isEmpty {
        tokens.append(token)
        token = ""
      }
      continue
    }
    token.append(char)
  }
  if !token.isEmpty { tokens.append(token) }
  return tokens.first?.lowercased() == "host" ? Array(tokens.dropFirst()) : []
}

func explicitAlias(
  profile: Profile?, selector: String, root: URL, config: URL, approve: (String, String) -> Bool
) throws {
  let remove = profile == nil
  let dir = config.deletingLastPathComponent()
  var d = stat()
  let createDirectory = lstat(dir.path, &d) < 0 && errno == ENOENT
  if !createDirectory {
    guard (d.st_mode & S_IFMT) == S_IFDIR, d.st_uid == getuid(), d.st_mode & 0o022 == 0 else {
      throw Wire.error
    }
  }
  let file = Darwin.open(config.path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW)
  var original = Data()
  var old = stat()
  let missing = (file < 0 && errno == ENOENT)
  guard file >= 0 || missing else { throw Wire.error }
  if file >= 0 {
    defer { close(file) }
    guard fstat(file, &old) == 0, (old.st_mode & S_IFMT) == S_IFREG, old.st_uid == getuid(),
      old.st_nlink == 1, old.st_mode & 0o022 == 0, old.st_size <= 1024 * 1024
    else { throw Wire.error }
    let handle = FileHandle(fileDescriptor: file, closeOnDealloc: false)
    original = try handle.read(upToCount: 1_048_577) ?? Data()
  }
  guard original.count <= 1_048_576, let text = String(data: original, encoding: .utf8) else {
    throw Wire.error
  }
  let id: String
  if let profile = profile {
    id = profile.id
  } else {
    let lines = text.components(separatedBy: "\n")
    let ids = lines.indices.compactMap { i -> String? in
      let parts = lines[i].split(separator: " ")
      guard parts.count == 5, Array(parts.prefix(3)) == ["#", "Want", "Pass"], parts[4] == "begin",
        parts[3].count == 32, parts[3].allSatisfy(\.isHexDigit), i + 2 < lines.count,
        parts[3] == selector || lines[i + 2] == "Host " + selector
      else { return nil }
      return String(parts[3])
    }
    if ids.isEmpty { return }
    guard ids.count == 1 else { throw Wire.error }
    id = ids[0]
  }
  let begin = "# Want Pass \(id) begin\n"
  let end = "# Want Pass \(id) end\n"
  var rest = text
  var previous = ""
  if let b = text.range(of: begin) {
    guard b.lowerBound == text.startIndex || text[text.index(before: b.lowerBound)] == "\n",
      let e = text.range(of: end, range: b.upperBound..<text.endIndex)
    else { throw Wire.error }
    previous = String(text[b.lowerBound..<e.upperBound])
    let inside = text[b.upperBound..<e.lowerBound]
    guard let split = inside.firstIndex(of: "\n") else { throw Wire.error }
    let content = String(inside[inside.index(after: split)...])
    let hash = SHA256.hash(data: Data(content.utf8)).map { String(format: "%02x", $0) }.joined()
    guard inside[..<split] == "# SHA256 " + hash else { throw Wire.error }
    rest.removeSubrange(b.lowerBound..<e.upperBound)
    guard !rest.contains(begin), !rest.contains(end) else { throw Wire.error }
  } else if text.contains(end) {
    throw Wire.error
  }
  let next: String
  if let profile = profile {
    let occupied = rest.split(whereSeparator: \.isNewline).contains { line in
      hostAliases(line).contains(where: { $0.caseInsensitiveCompare(profile.alias) == .orderedSame }
      )
    }
    guard !occupied else { throw Wire.error }
    let allowed = profile.options(root)
    let configOptions = allowed.map { item -> String in
      let parts = item.split(separator: "=", maxSplits: 1)
      let value = String(parts[1])
      // OpenSSH passes the rest of ProxyCommand to a shell. Its disabling token must be unquoted.
      if parts[0] == "ProxyCommand" { return "  ProxyCommand none" }
      let escaped = value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(
        of: "\"", with: "\\\""
      ).replacingOccurrences(of: "%", with: "%%")
      return "  \(parts[0]) \"\(escaped)\""
    }
    let content =
      ("Host " + profile.alias + "\n  HostName " + profile.host + "\n  User " + profile.user
        + "\n  Port " + String(profile.port) + "\n") + configOptions.joined(separator: "\n")
      + "\nHost *\n"
    let digest = SHA256.hash(data: Data(content.utf8)).map { String(format: "%02x", $0) }.joined()
    next = begin + "# SHA256 " + digest + "\n" + content + end
  } else {
    next = ""
  }
  if previous == next {
    try profile?.writeHostKey(in: root)
    return
  }
  guard approve(previous, next) else { return }
  if createDirectory {
    guard !remove, mkdir(dir.path, 0o700) == 0 else { throw Wire.error }
  }
  let result = Data((next + rest).utf8)
  let lockFD = Darwin.open(dir.path, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
  guard lockFD >= 0 else { throw Wire.error }
  defer { close(lockFD) }
  guard flock(lockFD, LOCK_EX | LOCK_NB) == 0 else { throw Wire.error }
  var now = stat()
  if missing {
    guard lstat(config.path, &now) < 0, errno == ENOENT else { throw Wire.error }
  } else {
    guard lstat(config.path, &now) == 0, now.st_ino == old.st_ino, now.st_dev == old.st_dev,
      now.st_uid == old.st_uid, now.st_nlink == 1, now.st_mode == old.st_mode,
      try Data(contentsOf: config) == original
    else { throw Wire.error }
  }
  let temp = dir.appendingPathComponent(".want-pass-" + UUID().uuidString)
  let tmp = Darwin.open(temp.path, O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW | O_WRONLY, 0o600)
  guard tmp >= 0 else { throw Wire.error }
  defer {
    close(tmp)
    unlink(temp.path)
  }
  try FileHandle(fileDescriptor: tmp, closeOnDealloc: false).write(contentsOf: result)
  try profile?.writeHostKey(in: root)
  guard fchmod(tmp, missing ? 0o600 : old.st_mode & 0o777) == 0, fsync(tmp) == 0,
    rename(temp.path, config.path) == 0, fsync(lockFD) == 0
  else { throw Wire.error }
}
