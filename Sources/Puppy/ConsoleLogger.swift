import Foundation

public struct ConsoleLogger: Loggerable, Sendable {
    public let label: String
    public let logLevel: LogLevel
    public let logFormat: LogFormattable?

    public init(_ label: String, logLevel: LogLevel = .trace, logFormat: LogFormattable? = nil) {
        self.label = label
        self.logLevel = logLevel
        self.logFormat = logFormat
    }

    public func log(_ level: LogLevel, string: String) async {
        print(string)
    }
}
