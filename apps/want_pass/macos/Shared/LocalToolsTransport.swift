import Darwin
import Foundation
import Security

enum ToolTransportError: Error { case denied }

enum LocalToolsTransport {
  static let error = ToolTransportError.denied
  static let limit = 65_536

  static func directory(_ identifier: String) throws -> URL {
    guard ["foundation.want.pass", "foundation.want.pass.dev"].contains(identifier),
      let home = getpwuid(getuid())?.pointee.pw_dir
    else { throw error }
    return URL(fileURLWithPath: String(cString: home), isDirectory: true)
      .appendingPathComponent("Library/Containers/\(identifier)/Data/.wpass", isDirectory: true)
  }

  static func checkDirectory(_ root: URL, create: Bool) throws {
    if create && mkdir(root.path, 0o700) != 0 && errno != EEXIST { throw error }
    var info = stat()
    guard lstat(root.path, &info) == 0, info.st_uid == getuid(),
      (info.st_mode & S_IFMT) == S_IFDIR, info.st_mode & 0o077 == 0
    else { throw error }
  }

  static func withAddress<T>(_ path: String, _ action: (UnsafePointer<sockaddr>, socklen_t) -> T)
    throws -> T
  {
    var address = sockaddr_un()
    let bytes = Array(path.utf8CString)
    guard !path.utf8.contains(0), bytes.count <= MemoryLayout.size(ofValue: address.sun_path) else {
      throw error
    }
    address.sun_family = sa_family_t(AF_UNIX)
    address.sun_len = UInt8(MemoryLayout<sockaddr_un>.size)
    withUnsafeMutableBytes(of: &address.sun_path) { raw in
      for (i, byte) in bytes.enumerated() { raw[i] = UInt8(bitPattern: byte) }
    }
    return withUnsafePointer(to: &address) { pointer in
      pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        action($0, socklen_t(MemoryLayout<sockaddr_un>.size))
      }
    }
  }

  static func configure(_ fd: Int32) throws {
    var one: Int32 = 1
    var timeout = timeval(tv_sec: 75, tv_usec: 0)
    let status = fcntl(fd, F_GETFL)
    // Darwin inherits O_NONBLOCK from the listening socket. Worker reads wait for a full frame.
    guard status >= 0, fcntl(fd, F_SETFL, status & ~O_NONBLOCK) == 0,
      fcntl(fd, F_SETFD, FD_CLOEXEC) == 0,
      setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout<Int32>.size)) == 0,
      setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size)) == 0,
      setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size)) == 0
    else { throw error }
  }

  static func verifyPeer(_ fd: Int32, expected: URL, identifier: String) throws {
    var uid = uid_t.max
    var gid = gid_t.max
    var token = audit_token_t()
    var length = socklen_t(MemoryLayout<audit_token_t>.size)
    guard getpeereid(fd, &uid, &gid) == 0, uid == getuid(),
      getsockopt(fd, SOL_LOCAL, LOCAL_PEERTOKEN, &token, &length) == 0,
      length == MemoryLayout<audit_token_t>.size
    else { throw error }
    let data = withUnsafeBytes(of: &token) { Data($0) }
    let flags = SecCSFlags(rawValue: 0)
    var guest: SecCode?
    var actual: SecStaticCode?
    var bundled: SecStaticCode?
    guard
      SecCodeCopyGuestWithAttributes(
        nil, [kSecGuestAttributeAudit as String: data] as CFDictionary, flags, &guest)
        == errSecSuccess,
      let guest = guest, SecCodeCheckValidity(guest, flags, nil) == errSecSuccess,
      SecCodeCopyStaticCode(guest, flags, &actual) == errSecSuccess, let actual = actual,
      SecStaticCodeCreateWithPath(expected as CFURL, flags, &bundled) == errSecSuccess,
      let bundled = bundled,
      SecStaticCodeCheckValidity(bundled, flags, nil) == errSecSuccess
    else { throw error }
    func identity(_ code: SecStaticCode) -> (String, Data, URL)? {
      var raw: CFDictionary?
      var url: CFURL?
      guard
        SecCodeCopySigningInformation(code, SecCSFlags(rawValue: kSecCSSigningInformation), &raw)
          == errSecSuccess,
        SecCodeCopyPath(code, flags, &url) == errSecSuccess, let url = url,
        let info = raw as? [String: Any],
        let id = info[kSecCodeInfoIdentifier as String] as? String,
        let hash = info[kSecCodeInfoUnique as String] as? Data
      else { return nil }
      return (id, hash, (url as URL).resolvingSymlinksInPath().standardizedFileURL)
    }
    guard let a = identity(actual), let b = identity(bundled), a.0 == identifier,
      a.0 == b.0, a.1 == b.1, a.2 == b.2
    else { throw error }
  }

  static func readBytes(_ fd: Int32, count: Int) throws -> Data {
    guard count >= 0 && count <= limit else { throw error }
    var data = Data(count: count)
    try data.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
      var offset = 0
      while offset < count {
        let bytes = Darwin.read(fd, buffer.baseAddress!.advanced(by: offset), count - offset)
        if bytes < 0 && errno == EINTR { continue }
        guard bytes > 0 else { throw error }
        offset += bytes
      }
    }
    return data
  }

  static func readPacket(_ fd: Int32) throws -> Data {
    let length = try readBytes(fd, count: 4).reduce(0) { $0 << 8 | Int($1) }
    guard length > 0 && length <= limit else { throw error }
    return try readBytes(fd, count: length)
  }

  static func string(_ bytes: Data) -> Data {
    var n = UInt32(bytes.count).bigEndian
    return withUnsafeBytes(of: &n) { Data($0) } + bytes
  }

  static func writePacket(_ fd: Int32, _ data: Data) throws {
    guard !data.isEmpty && data.count <= limit else { throw error }
    let packet = string(data)
    try packet.withUnsafeBytes { buffer in
      var offset = 0
      while offset < packet.count {
        let n = Darwin.write(fd, buffer.baseAddress!.advanced(by: offset), packet.count - offset)
        if n < 0 && errno == EINTR { continue }
        guard n > 0 else { throw error }
        offset += n
      }
    }
  }

  static func json(_ data: Data) throws -> [String: Any] {
    guard data.count <= limit,
      let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { throw error }
    return result
  }

  static func bytes(_ value: [String: Any]) throws -> Data {
    try JSONSerialization.data(withJSONObject: value)
  }
}
