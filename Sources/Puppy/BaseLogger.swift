import Foundation

public protocol Loggerable: Hashable {
    var label: String { get }
    var queue: DispatchQueue { get }

    func log(_ level: LogLevel, string: String)
}

public extension Loggerable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.label == rhs.label
    }
}

open class BaseLogger: Loggerable {
    public var logLevel: LogLevel = .trace

    public var format: LogFormattable?

    @inlinable
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) {
        queue.async {
            if level.rawValue < self.logLevel.rawValue {
                return
            }
            var formattedMessage = message
            if let format = self.format {
                formattedMessage = format.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: label, date: date, threadID: threadID)
            }
            self.log(level, string: formattedMessage)
        }
    }

    public let label: String
    public let queue: DispatchQueue

    public init(_ label: String) {
        self.label = label
        self.queue = DispatchQueue(label: label)
    }

    /// Needs to override this method in the inherited class.
    open func log(_ level: LogLevel, string: String) {
        print("NEED TO OVERRIDE!!: \(string)")
    }
}
