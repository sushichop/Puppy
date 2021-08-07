import Foundation

public protocol Loggerable {

    var label: String { get }
    var queue: DispatchQueue? { get }

    func log(_ level: LogLevel, string: String)
}

open class BaseLogger: Loggerable {

    public var enabled: Bool = true
    public var logLevel: LogLevel = .trace

    public func isLogging(_ level: LogLevel) -> Bool {
        return level.rawValue >= logLevel.rawValue
    }

    public var format: LogFormattable?

    @inlinable
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) {
        if !enabled { return }

        var formattedMessage = ""
        if let format = format {
            formattedMessage = format.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: label, date: date, threadID: threadID)
        } else {
            formattedMessage = message
        }

        if let queue = queue {
            queue.async {
                self.log(level, string: formattedMessage)
            }
        } else {
            log(level, string: formattedMessage)
        }
    }

    public let label: String
    public let queue: DispatchQueue?

    public init(_ label: String, asynchronous: Bool = true) {
        self.label = label
        self.queue = asynchronous ? DispatchQueue(label: label) : nil
    }

    open func log(_ level: LogLevel, string: String) {
        // Implements the logging feature here.
    }
}

extension BaseLogger: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }

    public static func == (lhs: BaseLogger, rhs: BaseLogger) -> Bool {
        return lhs.label == rhs.label
    }
}
