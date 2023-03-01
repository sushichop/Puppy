@preconcurrency import Dispatch
import Foundation
#if canImport(Darwin)
#elseif os(Linux)
import func CPuppy.cpuppy_sys_gettid
#elseif os(Windows)
import func WinSDK.GetCurrentThreadId
#else
#endif // canImport(Darwin)

public struct Puppy: Sendable {
    public private(set) var loggers: [any Loggerable] = []

    public init(loggers: [any Loggerable] = []) {
        self.loggers = loggers
    }

    public mutating func add(_ logger: any Loggerable) {
        if !(loggers.contains(where: { $0.label == logger.label })) {
            loggers.append(logger)
        }
    }

    public mutating func remove(_ logger: any Loggerable) {
        loggers.removeAll(where: { $0.label == logger.label })
    }

    public mutating func removeAll() {
        loggers.removeAll()
    }

    @inlinable
    public func trace(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.trace, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func verbose(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.verbose, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func debug(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.debug, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func info(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.info, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func notice(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.notice, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func warning(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.warning, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func error(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.error, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func critical(_ message: @autoclosure () -> String, tag: String = "", function: String = #function, file: String = #fileID, line: UInt = #line) {
        logMessage(.critical, message: message(), tag: tag, function: function, file: file, line: line)
    }

    @inlinable
    public func logMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String] = ["source": ""]) {
        let date = Date()
        let threadID = currentThreadID()

        for logger in loggers {
            logger.pickMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: logger.label, date: date, threadID: threadID)
        }
    }

    public func flush(_ timeout: Double = 3.0) -> WaitingResult {
        let date = Date()
        let threadID = currentThreadID()

        let group = DispatchGroup()
        for logger in loggers {
            group.enter()
            logger.flush {
                puppyDebug("before group.leave, date: \(date), threadID: \(threadID)")
                group.leave()
                puppyDebug("after group.leave, date: \(date), threadID: \(threadID)")
            }
        }

        let result = group.wait(timeout: .now() + .seconds(Int(timeout)))
        switch result {
        case .success:
            return .success
        case .timedOut:
            return .timeout
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

public enum WaitingResult {
    case success
    case timeout
}

@inlinable
func puppyDebug(_ items: Any) {
    #if DEBUG && PUPPY_DEBUG
    print("PUPPY_DEBUG:", items)
    #endif // DEBUG && PUPPY_DEBUG
}
