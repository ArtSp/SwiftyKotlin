
import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static func app(
        category: LoggerCategory
    ) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }
}

protocol LoggedInstance {
    static var loggerCategory: LoggerCategory { get }
}

extension LoggedInstance {
    static var logger: Logger { Logger.app(category: loggerCategory) }
    var logger: Logger { Self.logger }
}

enum LoggerCategory: String {
    case viewModel
    case dependencyInjection
    // TODO: Add new categories
}
