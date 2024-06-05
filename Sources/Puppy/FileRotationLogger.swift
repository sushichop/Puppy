@preconcurrency import Dispatch
import Foundation

public struct FileRotationLogger: FileLoggerable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    public let fileURL: URL
    public let filePermission: String

    public let compressArchived: Bool

    let rotationConfig: RotationConfig
    private weak var delegate: FileRotationLoggerDelegate?

    private var dateFormat: DateFormatter

    public init(_ label: String,
                logLevel: LogLevel = .trace,
                logFormat: LogFormattable? = nil,
                fileURL: URL,
                filePermission: String = "640",
                rotationConfig: RotationConfig,
                delegate: FileRotationLoggerDelegate? = nil,
                compressArchived: Bool = false) throws {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat

        self.dateFormat = DateFormatter()
        self.dateFormat.dateFormat = "yyyyMMdd'T'HHmmssZZZZZ"
        self.dateFormat.timeZone = TimeZone(identifier: "UTC")
        self.dateFormat.locale = Locale(identifier: "en_US_POSIX")

        self.fileURL = fileURL
        puppyDebug("initialized, fileURL: \(fileURL)")
        self.filePermission = filePermission

        self.compressArchived = compressArchived

        self.rotationConfig = rotationConfig
        self.delegate = delegate

        try validateFileURL(fileURL)
        try validateFilePermission(fileURL, filePermission: filePermission)
        try openFile()
    }

    public func log(_ level: LogLevel, string: String) {
        append(level, string: string)
        rotateFiles()
    }

    private func fileSize(_ fileURL: URL) throws -> UInt64 {
        #if os(Windows)
        return try FileManager.default.windowsFileSize(atPath: fileURL.path)
        #else
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        // swiftlint:disable force_cast
        return attributes[.size] as! UInt64
        // swiftlint:enable force_cast
        #endif
    }

    private func rotateFiles() {
        guard let size = try? fileSize(fileURL), size > rotationConfig.maxFileSize else { return }

        // Rotates old archived files.
        rotateOldArchivedFiles()

        // Archives the target file.
        archiveTargetFiles()

        // Removes extra archived files.
        removeArchivedFiles(fileURL, maxArchivedFilesCount: rotationConfig.maxArchivedFilesCount)
        if self.compressArchived {
            removeCompressedArchives(fileURL, maxArchivedFilesCount: rotationConfig.maxArchivedFilesCount)
        }
        // Opens a new target file.
        do {
            puppyDebug("will openFile in rotateFiles")
            try openFile()
        } catch {
            print("error in openFile while rotating, error: \(error.localizedDescription)")
        }
    }

    private func archiveTargetFiles() {
        do {
            var archivedFileURL: URL
            switch rotationConfig.suffixExtension {
            case .numbering:
                archivedFileURL = fileURL.appendingPathExtension("1")
            case .date_uuid:
                archivedFileURL = fileURL.appendingPathExtension(dateFormatter(Date(), withFormatter: self.dateFormat) + "_" + UUID().uuidString.lowercased())
            }
            try FileManager.default.moveItem(at: fileURL, to: archivedFileURL)
            delegate?.fileRotationLogger(self, didArchiveFileURL: fileURL, toFileURL: archivedFileURL)

            if self.compressArchived {
                Task.detached { [archivedFileURL] in
                    do {
                        let archivePath = Compressor.uniqueName(file: archivedFileURL.deletingPathExtension().toPath())
                        try Compressor.lzfse(src: archivedFileURL.toPath(), dst: archivePath)
                        try FileManager.default.removeItem(atPath: archivedFileURL.toPath())

                        delegate?.fileRotationLogger(self, didCompressArchivedFileURL: archivedFileURL, toCompressedFile: URL(path: archivePath))
                    } catch {
                        puppyDebug("compressing rotated log file: \(error.localizedDescription)")
                    }
                }
            }

        } catch {
            print("error in archiving the target file, error: \(error.localizedDescription)")
        }
    }

    private func rotateOldArchivedFiles() {
        switch rotationConfig.suffixExtension {
        case .numbering:
            do {
                let oldArchivedFileURLs = ascArchivedFileURLs(fileURL, isIncluded: {
                    $0 != fileURL && $0.deletingPathExtension() == fileURL
                })
                for (index, oldArchivedFileURL) in oldArchivedFileURLs.enumerated() {
                    let generationNumber = oldArchivedFileURLs.count + 1 - index
                    let rotatedFileURL = oldArchivedFileURL.deletingPathExtension().appendingPathExtension("\(generationNumber)")
                    puppyDebug("generationNumber: \(generationNumber), rotatedFileURL: \(rotatedFileURL)")
                    if !FileManager.default.fileExists(atPath: rotatedFileURL.path) {
                        try FileManager.default.moveItem(at: oldArchivedFileURL, to: rotatedFileURL)
                    }
                }
            } catch {
                print("error in rotating old archive files, error: \(error.localizedDescription)")
            }
        case .date_uuid:
            break
        }
    }

    private func ascArchivedFileURLs(_ fileURL: URL, isIncluded: (URL) throws -> Bool) -> [URL] {
        var ascArchivedFileURLs: [URL] = []
        do {
            let archivedDirectoryURL: URL = fileURL.deletingLastPathComponent()
            let archivedFileURLs = try FileManager.default.contentsOfDirectory(atPath: archivedDirectoryURL.path)
                .map { archivedDirectoryURL.appendingPathComponent($0) }
                .filter(isIncluded)

            ascArchivedFileURLs = try archivedFileURLs.sorted {
                #if os(Windows)
                let modificationTime0 = try FileManager.default.windowsModificationTime(atPath: $0.path)
                let modificationTime1 = try FileManager.default.windowsModificationTime(atPath: $1.path)
                return modificationTime0 < modificationTime1
                #else
                // swiftlint:disable force_cast
                let modificationDate0 = try FileManager.default.attributesOfItem(atPath: $0.path)[.modificationDate] as! Date
                let modificationDate1 = try FileManager.default.attributesOfItem(atPath: $1.path)[.modificationDate] as! Date
                // swiftlint:enable force_cast
                return modificationDate0.timeIntervalSince1970 < modificationDate1.timeIntervalSince1970
                #endif
            }
        } catch {
            print("error in ascArchivedFileURLs, error: \(error.localizedDescription)")
        }
        puppyDebug("ascArchivedFileURLs: \(ascArchivedFileURLs)")
        return ascArchivedFileURLs
    }

    private func removeArchivedFiles(_ fileURL: URL, maxArchivedFilesCount: UInt8) {
        do {
            let archivedFileURLs = ascArchivedFileURLs(fileURL, isIncluded: {
                $0 != fileURL && $0.deletingPathExtension() == fileURL
            })
            if archivedFileURLs.count > maxArchivedFilesCount {
                for index in 0 ..< archivedFileURLs.count - Int(maxArchivedFilesCount) {
                    puppyDebug("\(archivedFileURLs[index]) will be removed...")
                    try FileManager.default.removeItem(at: archivedFileURLs[index])
                    puppyDebug("\(archivedFileURLs[index]) has been removed")
                    delegate?.fileRotationLogger(self, didRemoveArchivedFileURL: archivedFileURLs[index])
                }
            }
        } catch {
            print("error in removing extra archived files, error: \(error.localizedDescription)")
        }
    }
    
    private func removeCompressedArchives(_ fileURL: URL, maxArchivedFilesCount: UInt8) {
        do {
            let archivedFileURLs = ascArchivedFileURLs(fileURL, isIncluded: {
                $0.pathExtension == "archive"
            })
            if archivedFileURLs.count > maxArchivedFilesCount {
                for index in 0 ..< archivedFileURLs.count - Int(maxArchivedFilesCount) {
                    puppyDebug("\(archivedFileURLs[index]) will be removed...")
                    try FileManager.default.removeItem(at: archivedFileURLs[index])
                    puppyDebug("\(archivedFileURLs[index]) has been removed")
                    delegate?.fileRotationLogger(self, didRemoveCompressedFileURL: archivedFileURLs[index])
                }
            }
        } catch {
            print("error in removing extra archived files, error: \(error.localizedDescription)")
        }
    }
}

public struct RotationConfig: Sendable {
    public enum SuffixExtension: Sendable {
        case numbering
        case date_uuid
    }
    public var suffixExtension: SuffixExtension

    public typealias ByteCount = UInt64
    public var maxFileSize: ByteCount
    public var maxArchivedFilesCount: UInt8

    public init(suffixExtension: SuffixExtension = .numbering, maxFileSize: ByteCount = 10 * 1024 * 1024, maxArchivedFilesCount: UInt8 = 5) {
        self.suffixExtension = suffixExtension
        self.maxFileSize = maxFileSize
        self.maxArchivedFilesCount = maxArchivedFilesCount
    }
}

public protocol FileRotationLoggerDelegate: AnyObject, Sendable {
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didArchiveFileURL: URL, toFileURL: URL)
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveArchivedFileURL: URL)
    func fileRotationLogger(_ fileRotationlogger: FileRotationLogger, didCompressArchivedFileURL: URL, toCompressedFile: URL)
    func fileRotationLogger(_ fileRotationLogger: FileRotationLogger, didRemoveCompressedFileURL: URL)
}

extension URL {
    public func toPath() -> String {
        if #available(macOS 13.0, *) {
            return self.path(percentEncoded: false)
        } else {
            return self.path
        }
    }

    init(path: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: path)
        }
        self.init(fileURLWithPath: path)
    }
}
