import Foundation

public enum LogLevel: Equatable, Hashable, Comparable, CaseIterable {
	case debug
	case info
	case warning
	case error
	case fatal
}

extension LogLevel {
	public var string: String {
		switch self {
			case .debug:
				return "debug"
			case .info:
				return "info"
			case .warning:
				return "warning"
			case .error:
				return "error"
			case .fatal:
				return "fatal"
		}
	}
}

public struct Log {
	public var log: (Any, LogLevel) -> Void
	
	public init(
		log: @escaping (Any, LogLevel) -> Void
	) {
		self.log = log
	}
}

extension Log {
	public static var ignore: Log {
		.init(
			log: { _, _ in }
		)
	}
	
	public static var console: Log {
		.init(
			log: { value, level in
				print("> \(level.string): \(value)")
			}
		)
	}
	
	public static var consoleLogErrors: Log {
		Log.console.ignoring(upTo: .warning)
	}
}

extension Log {
	public func ignoring(upTo minLevel: LogLevel) -> Log {
		.init { object, level in
			guard level > minLevel else {
				return
			}
			
			self.log(object, level)
		}
	}
}

extension Log {
	public func debug(_ value: Any) {
		self.log(value, .debug)
	}
	
	public func info(_ value: Any) {
		self.log(value, .info)
	}
	
	public func warning(_ value: Any) {
		self.log(value, .warning)
	}
	
	public func error(_ value: Any) {
		self.log(value, .error)
	}
	
	public func fatal(_ value: Any) {
		self.log(value, .fatal)
	}
}

extension Log {
	public func adding(`prefix`: String) -> Log {
		.init { message, level in
			self.log("\(prefix)\(message)", level)
		}
	}
	
	public func adding(suffix: String) -> Log {
		.init { message, level in
			self.log("\(message)\(suffix)", level)
		}
	}
}

extension Log {
	public func concat(with log: Log) -> Log {
		.init { object, level in
			self.log(object, level)
			log.log(object, level)
		}
	}
}

extension Array where Element == Log {
	public var reduced: Log {
		self.reduce(into: Log.ignore) { partialResult, log in
			partialResult = partialResult.concat(with: log)
		}
	}
}
