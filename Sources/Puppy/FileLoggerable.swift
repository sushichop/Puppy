import Foundation

public enum FlushMode: Sendable {
    case always
    case manual
}

/// Writing the file log to the disk can fail e.g. if the disk is full.
/// The `FileWritingErrorHandlingMode` enum specifies how errors should be handled.
/// - assert uses assertionFailure to stop execution for debug builds and ignores failures in release builds
/// - print only prints the error message to the standard output
/// - force crashes for all builds, if logging fails by force trying to write the file. Default behavior, if no other option is specified
public enum FileWritingErrorHandlingMode: Sendable {
    case assert
    case print
    case force
}

public protocol FileLoggerable: Loggerable, Sendable {
    var fileURL: URL { get }
    var filePermission: String { get }
}

extension FileLoggerable {
    private var uintPermission: UInt16 {
        return UInt16(filePermission, radix: 8)!
    }

    public func delete(_ url: URL) async throws -> URL {
        let task = Task(priority: .utility) {
          do {
            try FileManager.default.removeItem(at: url)
          } catch {
            throw FileError.deletingFailed(at: url)
          }
          return url
        }
        return try await task.value
    }

    public func flush(_ url: URL) async {
      let task = Task(priority: .utility) {
        let handle = try? FileHandle(forWritingTo: url)
        try? handle?.synchronize()
        try? handle?.close()
      }
      await task.value
    }

    func openFile() throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            puppyDebug("created directoryURL, directoryURL: \(directoryURL)")
        } catch {
            throw FileError.creatingDirectoryFailed(at: directoryURL)
        }

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let successful = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: [FileAttributeKey.posixPermissions: uintPermission])
            if successful {
                puppyDebug("succeeded in creating filePath")
            } else {
                throw FileError.creatingFileFailed(at: fileURL)
            }
        } else {
            puppyDebug("filePath exists, filePath: \(fileURL.path)")
        }

        var handle: FileHandle!
        do {
            defer {
                try? handle?.synchronize()
                try? handle?.close()
            }
            handle = try FileHandle(forWritingTo: fileURL)
        } catch {
            throw FileError.openingForWritingFailed(at: fileURL)
        }
    }

    func validateFileURL(_ url: URL) throws {
        if url.hasDirectoryPath {
            throw FileError.isNotFile(url: url)
        }
    }

    func validateFilePermission(_ url: URL, filePermission: String) throws {
        let min = UInt16("000", radix: 8)!
        let max = UInt16("777", radix: 8)!
        if let uintPermission = UInt16(filePermission, radix: 8), uintPermission >= min, uintPermission <= max {
        } else {
            throw FileError.invalidPermission(at: url, filePermission: filePermission)
        }
    }

    func append(_ level: LogLevel, string: String, flushMode: FlushMode = .always, writeMode: FileWritingErrorHandlingMode = .force) {
        var handle: FileHandle!
        do {
            defer {
                if flushMode == .always {
                    try? handle?.synchronize()
                }
                try? handle?.close()
            }
            handle = try FileHandle(forWritingTo: fileURL)
            _ = try handle?.seekToEndCompatible()
            if let data = (string + "\r\n").data(using: .utf8) {

                switch writeMode {
                case .force:
                    // swiftlint:disable force_try
                    try! handle?.writeCompatible(contentsOf: data)
                    // swiftlint:enable force_try
                case .assert, .print:
                    do {
                        try handle?.writeCompatible(contentsOf: data)
                    } catch {
                        let message = "error in appending data in a file, error: \(error.localizedDescription), file: \(fileURL)"
                        if writeMode == .assert {
                            assertionFailure(message)
                        } else {
                            print(message)
                        }
                    }
                }
            }
        } catch {
            print("error in appending data in a file, error: \(error.localizedDescription), file: \(fileURL)")
        }
    }
}

extension FileHandle {
    func seekToEndCompatible() throws -> UInt64 {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            return try seekToEnd()
        } else {
            return seekToEndOfFile()
        }
    }

    func writeCompatible(contentsOf data: Data) throws {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            try write(contentsOf: data)
        } else {
            write(data)
        }
    }
}
