#if canImport(Logging)
import Foundation
@_exported import Logging

public struct PuppyLogHandler: LogHandler, Sendable {
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }

    private let label: String
    private let puppy: Puppy

    public init(label: String, puppy: Puppy, metadata: Logger.Metadata = [:]) {
        self.label = label
        self.puppy = puppy
        self.metadata = metadata
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {

        let metadata = !mergedMetadata(metadata).isEmpty ? "\(mergedMetadata(metadata))" : ""
        let swiftLogInfo = ["label": label, "source": source, "metadata": metadata]
        puppy.logMessage(level.toPuppy(), message: "\(message)", tag: "swiftlog", function: function, file: file, line: line, swiftLogInfo: swiftLogInfo)
    }

    private func mergedMetadata(_ metadata: Logger.Metadata?) -> Logger.Metadata {
        var mergedMetadata: Logger.Metadata
        if let metadata = metadata {
            mergedMetadata = self.metadata.merging(metadata, uniquingKeysWith: { _, new in new })
        } else {
            mergedMetadata = self.metadata
        }
        return mergedMetadata
    }
}

extension Logger.Level {
    func toPuppy() -> LogLevel {
        switch self {
        case .trace:
            return .trace
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            return .notice
        case .warning:
            return .warning
        case .error:
            return .error
        case .critical:
            return .critical
        }
    }
}

#endif // canImport(Logging)
