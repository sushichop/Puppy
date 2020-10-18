import Foundation

public class ConsoleLogger: BaseLogger {

    public override var queue: DispatchQueue! {
        return Self.consoleLoggerQueue
    }

    private static let consoleLoggerQueue = DispatchQueue(label: "net.sushichop.puppy.consolelogger")

    public override func log(_ level: LogLevel, string: String) {
        print(string)
    }
}
