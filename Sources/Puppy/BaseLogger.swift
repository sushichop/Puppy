import Foundation

open class BaseLogger {
    public let label: String
    public let queue: DispatchQueue
    public var logLevel: LogLevel = .trace
    public var logFormat: LogFormattable?

    public init(_ label: String) {
        self.label = label
        self.queue = DispatchQueue(label: label)
    }

    @inlinable
    func pickMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) {
        queue.async {
            if level.rawValue < self.logLevel.rawValue {
                return
            }
            var formattedMessage = message
            if let format = self.logFormat {
                formattedMessage = format.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: label, date: date, threadID: threadID)
            }
            self.log(level, string: formattedMessage)
        }
    }

    /// Needs to override this method in the inherited class.
    open func log(_ level: LogLevel, string: String) {
        print("NEED TO OVERRIDE!!: \(string)")
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
