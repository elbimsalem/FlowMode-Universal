import Foundation
import os.log

enum LogLevel {
    case debug, info, warning, error
}

struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "FlowMode"
    
    static let timer = Logger(category: "Timer")
    static let subscription = Logger(category: "Subscription")
    static let sound = Logger(category: "Sound")
    static let notification = Logger(category: "Notification")
    static let background = Logger(category: "Background")
    
    private let osLog: OSLog
    
    private init(category: String) {
        self.osLog = OSLog(subsystem: Logger.subsystem, category: category)
    }
    
    func log(_ level: LogLevel, _ message: String) {
        let type: OSLogType
        switch level {
        case .debug: type = .debug
        case .info: type = .info
        case .warning: type = .default
        case .error: type = .error
        }
        os_log("%{public}@", log: osLog, type: type, message)
    }
}