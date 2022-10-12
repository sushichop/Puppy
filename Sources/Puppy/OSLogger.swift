#if canImport(Darwin)
@preconcurrency import Dispatch
@preconcurrency import os
import Foundation

public final class OSLogger: Loggerable, Sendable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    private let osLog: OSLog

    public init(_ label: String, logLevel: LogLevel = .trace, logFormat: LogFormattable? = nil,
                category: String = "Puppy") {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat
        self.osLog = OSLog(subsystem: label, category: category)
    }

    public func log(_ level: LogLevel, string: String) {
        let type = logType(level)
        os_log("%{public}@", log: osLog, type: type, string)
    }

    private func logType(_ level: LogLevel) -> OSLogType {
        switch level {
        case .trace:
            // `OSLog` doesn't have `trace`, so use `debug` instead.
            return .debug
        case .verbose:
            // `OSLog` doesn't have `verbose`, so use `debug` instead.
            return .debug
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            // `OSLog` doesn't have `notice`, so use `info` instead.
            return .info
        case .warning:
            // `OSLog` doesn't have `warning`, so use `default` instead.
            return .default
        case .error:
            return .error
        case .critical:
            // `OSLog` doesn't have `critical`, so use `.fault` instead.
            return .fault
        }
    }
}

#endif // canImport(Darwin)
