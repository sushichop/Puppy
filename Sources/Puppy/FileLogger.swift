@preconcurrency import Dispatch
import Foundation

public struct FileLogger: FileLoggerable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    public let fileURL: URL
    public let filePermission: String

    public let flushMode: FlushMode
    public let writeMode: FileWritingErrorHandlingMode

    public init(_ label: String, logLevel: LogLevel = .trace, logFormat: LogFormattable? = nil, fileURL: URL, filePermission: String = "640", flushMode: FlushMode = .always, writeMode: FileWritingErrorHandlingMode = .force) throws {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat

        self.fileURL = fileURL
        puppyDebug("initialized, fileURL: \(fileURL)")
        self.filePermission = filePermission

        self.flushMode = flushMode
        self.writeMode = writeMode

        try validateFileURL(fileURL)
        try validateFilePermission(fileURL, filePermission: filePermission)
        try openFile()
    }

    public func log(_ level: LogLevel, string: String) {
        append(level, string: string, flushMode: flushMode, writeMode: writeMode)
    }
}
