#if os(Linux)
@preconcurrency import Dispatch
import Foundation
import func CPuppy.cpuppy_syslog

public final class SystemLogger: Loggerable, Sendable {
    public let label: String
    public let queue: DispatchQueue
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    public init(_ label: String, logLevel: LogLevel = .trace, logFormat: LogFormattable? = nil) {
        self.label = label
        self.queue = DispatchQueue(label: label)
        self.logLevel = logLevel
        self.logFormat = logFormat
    }

    public func log(_ level: LogLevel, string: String) {
        string.withCString {
            let priority = logPriority(level)
            cpuppy_syslog(priority, $0)
        }
    }

    private func logPriority(_ level: LogLevel) -> Int32 {
        switch level {
        case .trace:
            // `syslog` doesn't have `trace`, so use `LOG_DEBUG` instead.
            return LOG_DEBUG
        case .verbose:
            // `syslog` doesn't have `verbose`, so use `LOG_DEBUG` instead.
            return LOG_DEBUG
        case .debug:
            return LOG_DEBUG
        case .info:
            return LOG_INFO
        case .notice:
            return LOG_NOTICE
        case .warning:
            return LOG_WARNING
        case .error:
            return LOG_ERR
        case .critical:
            return LOG_CRIT
        }
    }
}

#endif // os(Linux)
