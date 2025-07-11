@preconcurrency import Dispatch
import Foundation

public struct FileRotationLogger: FileLoggerable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    public let fileURL: URL
    public let filePermission: String
    
    #if os(iOS) || os(macOS)
    public let fileProtectionType: FileProtectionType?
    public let isExcludedFromBackup: Bool
    #endif

    public let flushMode: FlushMode
    public let writeMode: FileWritingErrorHandlingMode

    let rotationConfig: RotationConfig
    private weak var delegate: FileRotationLoggerDelegate?

    private let dateFormat: DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMdd'T'HHmmssZZZZZ"
        dateFormat.timeZone = TimeZone(identifier: "UTC")
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat
    }()

    #if os(iOS) || os(macOS)
    public init(_ label: String,
                logLevel: LogLevel = .trace,
                logFormat: LogFormattable? = nil,
                fileURL: URL,
                filePermission: String = "640",
                fileProtectionType: FileProtectionType? = nil,
                isExcludedFromBackup: Bool = false,
                rotationConfig: RotationConfig,
                flushMode: FlushMode = .always,
                writeMode: FileWritingErrorHandlingMode = .force,
                delegate: FileRotationLoggerDelegate? = nil) throws {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat
        self.fileURL = fileURL
        self.filePermission = filePermission
        self.fileProtectionType = fileProtectionType
        self.isExcludedFromBackup = isExcludedFromBackup
        self.flushMode = flushMode
        self.writeMode = writeMode
        self.rotationConfig = rotationConfig
        self.delegate = delegate
        try commonInit()
    }
    #else
    public init(_ label: String,
                logLevel: LogLevel = .trace,
                logFormat: LogFormattable? = nil,
                fileURL: URL,
                filePermission: String = "640",
                rotationConfig: RotationConfig,
                flushMode: FlushMode = .always,
                writeMode: FileWritingErrorHandlingMode = .force,
                delegate: FileRotationLoggerDelegate? = nil) throws {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat
        self.fileURL = fileURL
        self.filePermission = filePermission
        self.flushMode = flushMode
        self.writeMode = writeMode
        self.rotationConfig = rotationConfig
        self.delegate = delegate
        try commonInit()
    }
    #endif

    private func commonInit() throws {
        puppyDebug("initialized, fileURL: \(fileURL)")
        try validateFileURL(fileURL)
        try validateFilePermission(fileURL, filePermission: filePermission)
        try openFile()
    }

    public func log(_ level: LogLevel, string: String) {
        rotateFiles()
        append(level, string: string, flushMode: flushMode, writeMode: writeMode)
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
        } catch {
            print("error in archiving the target file, error: \(error.localizedDescription)")
        }
    }

    private func rotateOldArchivedFiles() {
        switch rotationConfig.suffixExtension {
        case .numbering:
            do {
                let oldArchivedFileURLs = ascArchivedFileURLs(fileURL)
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

    private func ascArchivedFileURLs(_ fileURL: URL) -> [URL] {
        var ascArchivedFileURLs: [URL] = []
        do {
            let archivedDirectoryURL: URL = fileURL.deletingLastPathComponent()
            let archivedFileURLs = try FileManager.default.contentsOfDirectory(atPath: archivedDirectoryURL.path)
                .map { archivedDirectoryURL.appendingPathComponent($0) }
                .filter { $0 != fileURL && $0.deletingPathExtension() == fileURL }

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
            let archivedFileURLs = ascArchivedFileURLs(fileURL)
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
}
