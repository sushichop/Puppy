import Foundation
#if canImport(Darwin)
#elseif os(Linux)
import func CPuppy.cpuppy_sys_gettid
#elseif os(Windows)
import func WinSDK.GetCurrentThreadId
#else
#endif // canImport(Darwin)

public class Puppy {

    public private(set) var loggers = Set<BaseLogger>()

    public init() {}

    public func add(_ logger: BaseLogger) {
        if !(loggers.contains(logger)) {
            loggers.insert(logger)
        }
    }

    public func add(_ logger: BaseLogger, withLevel: LogLevel) {
        if !(loggers.contains(logger)) {
            logger.logLevel = withLevel
            loggers.insert(logger)
        }
    }

    public func remove(_ logger: BaseLogger) {
        if loggers.contains(logger) {
            loggers.remove(logger)
        }
    }

    public func removeAll() {
        loggers.removeAll()
    }

    @inlinable
    public func trace(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.trace, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func verbose(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.verbose, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func debug(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.debug, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func info(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.info, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func notice(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.notice, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func warning(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.warning, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func error(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.error, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func critical(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #file, line: UInt = #line) {
        logMessage(.critical, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    func logMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String] = ["source": ""]) {
        let date = Date()
        let threadID = currentThreadID()

        let targetedLoggers = loggers.filter { $0.isLogging(level) }
        for logger in targetedLoggers {
            logger.formatMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: logger.label, date: date, threadID: threadID)
        }
    }

    @usableFromInline
    func currentThreadID() -> UInt64 {
        var threadID: UInt64 = 0
        #if canImport(Darwin)
        pthread_threadid_np(nil, &threadID)
        #elseif os(Linux)
        threadID = cpuppy_sys_gettid()
        #elseif os(Windows)
        threadID = UInt64(GetCurrentThreadId())
        #else
        #endif // canImport(Darwin)
        return threadID
    }
}

@inlinable
func puppyDebug(_ items: Any) {
    #if DEBUG && PUPPY_DEBUG
    print("PUPPY_DEBUG:", items)
    #endif // DEBUG && PUPPY_DEBUG
}
