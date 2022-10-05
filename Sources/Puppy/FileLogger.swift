import Foundation

public class FileLogger: BaseLogger {

    public enum FlushMode {
        case always
        case manual
    }
    public private(set) var flushMode: FlushMode

    private let filePermission: String
    private var uintPermission: UInt16 {
        return UInt16(filePermission, radix: 8)!
    }

    let fileURL: URL

    public init(_ label: String, fileURL: URL, filePermission: String = "640", flushMode: FlushMode = .always) throws {
        self.fileURL = fileURL
        self.filePermission = filePermission
        self.flushMode = flushMode
        puppyDebug("initialized, fileURL: \(fileURL)")
        super.init(label)
        try validateFileURL(fileURL)
        try validateFilePermission(fileURL, filePermission: filePermission)
        try openFile()
    }

    public override func log(_ level: LogLevel, string: String) {
        var handle: FileHandle!
        do {
            defer {
                if flushMode == .always {
                    try? handle?.synchronize()
                }
                try? handle?.close()
            }

            handle = try FileHandle(forWritingTo: fileURL)
            _ = try handle?.seekToEnd()
            if let data = (string + "\r\n").data(using: .utf8) {
                // swiftlint:disable force_try
                try! handle?.write(contentsOf: data)
                // swiftlint:enable force_try

            }
        } catch {
            print("error in appending data in a file, error: \(error.localizedDescription), file: \(fileURL)")
        }
    }

    public func delete(_ url: URL) -> Result<URL, FileError> {
        queue!.sync {
            Result { try FileManager.default.removeItem(at: url) }
                .map { url }
                .mapError { _ in
                    FileError.deletingFailed(at: url)
                }
        }
    }

    public func delete(_ url: URL, completion: @escaping (Result<URL, FileError>) -> Void) {
        queue!.async {
            let result = Result { try FileManager.default.removeItem(at: url) }
                .map { url }
                .mapError { _ in
                    FileError.deletingFailed(at: url)
                }
            completion(result)
        }
    }

    public func flush(_ url: URL) {
        queue!.sync {
            let handle = try? FileHandle(forWritingTo: url)
            try? handle?.synchronize()
            try? handle?.close()
        }
    }

    public func flush(_ url: URL, completion: @escaping () -> Void) {
        queue!.async {
            let handle = try? FileHandle(forWritingTo: url)
            try? handle?.synchronize()
            try? handle?.close()
            completion()
        }
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

    private func validateFileURL(_ url: URL) throws {
        if url.hasDirectoryPath {
            throw FileError.isNotFile(url: url)
        }
    }

    private func validateFilePermission(_ url: URL, filePermission: String) throws {
        let min = UInt16("000", radix: 8)!
        let max = UInt16("777", radix: 8)!
        if let uintPermission = UInt16(filePermission, radix: 8), uintPermission >= min, uintPermission <= max {
        } else {
            throw FileError.invalidPermission(at: url, filePermission: filePermission)
        }
    }
}
