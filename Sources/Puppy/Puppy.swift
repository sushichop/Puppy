import Foundation
#if canImport(Darwin)
#elseif os(Linux)
import func CPuppy.cpuppy_sys_gettid
#elseif os(Windows)
import func WinSDK.GetCurrentThreadId
#else
#endif // canImport(Darwin)

import AsyncQueue

public struct Puppy: Sendable {
    public private(set) var loggers: [any Loggerable] = []

    /// Used to queue all messages in order.
    /// > Note: This needs to be public to be useable in an inlinable function
    public let fifoQueue: FIFOQueue

    public init(loggers: [any Loggerable] = [], fifoQueue: FIFOQueue = FIFOQueue()) {
        self.loggers = loggers
        self.fifoQueue = fifoQueue
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

    /// Will wait for all logs to finish
    public func wait() async {
        await fifoQueue.await {
           // this should be empty to allow all to finish
        }
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
    /// The message is added to a FIFO queue and function returns immediatly, use the ``wait()`` function to wait for all logs to finish
    func logMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String] = ["source": ""]) {
        let date = Date()
        let threadID = currentThreadID()

        for logger in loggers {
            fifoQueue.async {
                await logger.pickMessage(level, message: message, tag: tag, function: function, file: file, line: line, swiftLogInfo: swiftLogInfo, label: logger.label, date: date, threadID: threadID)
            }
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
