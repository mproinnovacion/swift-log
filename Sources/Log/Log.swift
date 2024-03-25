import Foundation
import os

public struct Log<Message> {
	public var log: (Message) -> Void
	
	public init(log: @escaping (Message) -> Void) {
		self.log = log
	}
}

extension Log {
	public static var ignore: Self {
		.init { _ in }
	}
	
	public func combined(with: Log) -> Self {
		.init { message in
			self.log(message)
			with.log(message)
		}
	}
}

extension Array {
	public func reduced<Message>() -> Log<Message> where Element == Log<Message> {
		self.reduce(into: Log.ignore) { partialResult, log in
			partialResult = partialResult.combined(with: log)
		}
	}
}

extension Log where Message == String {
	public static var print: Self {
		.init { value in
			Swift.print(value)
		}
	}
}

extension Log where Message == String {
	public func adding(`prefix`: String) -> Log {
		.init { message in
			self.log("\(prefix)\(message)")
		}
	}
	
	public func adding(suffix: String) -> Log {
		.init { message in
			self.log("\(message)\(suffix)")
		}
	}
}

extension Log {
	@inlinable
	public func pullback<NewMessage>(
	_ f: @escaping (NewMessage) -> Message
	) -> Log<NewMessage> {
		.init { message in
			self.log(f(message))
		}
	}
}

extension Log where Message == String {
	public func maxLength(
		_ max: Int
	) -> Self {
		.init { message in
			self.log(String(message.prefix(max)))
		}
	}
}

@inlinable
public func formatTags<Tag>(_ tags: Set<Tag>) -> String {
	tags.map { tag in
		"#\(tag)"
	}.joined(separator: " ")
}

public enum LogLevel: Equatable, Hashable, Comparable, CaseIterable {
	case info
	case debug
	case warning
	case error
	case fatal
	
	public var formatted: String {
		switch self {
			case .debug:
				return "🔎 debug"
			case .info:
				return "ℹ️ info"
			case .warning:
				return "⚠️ warning"
			case .error:
				return "🚫 error"
			case .fatal:
				return "💀 fatal"
		}
	}
}

public struct DefaultMessage<Tag: Hashable>: Equatable {
	public var value: String
	public var level: LogLevel
	public var tags: Set<Tag>
	
	public init(value: String, level: LogLevel, tags: Set<Tag>) {
		self.value = value
		self.level = level
		self.tags = tags
	}
}

extension DefaultMessage {
	@inlinable
	public var formatted: String {
		let tags = formatTags(tags)
		return "\(level.formatted): \(value) \(tags)"
	}
}

extension Log {
	public func maxLength<Tag>(
		_ max: Int
	) -> Self
	where Message == DefaultMessage<Tag> {
		self.pullback { message in
			var clipped = message
			clipped.value = String(clipped.value.prefix(max))
			return clipped
		}
	}
	
	public func maxLines<Tag>(
		_ max: Int
	) -> Self
	where Message == DefaultMessage<Tag> {
		self.pullback { message in
			var clipped = message
			clipped.value = clipped.value.components(separatedBy: .newlines).prefix(max).joined(separator: "\n")
			return clipped
		}
	}
}

extension Log {
	public func adding<Tag>(`prefix`: String) -> Self
	where Message == DefaultMessage<Tag> {
		self.pullback { message in
			var prefixed = message
			prefixed.value = "\(prefix)\(prefixed.value)"
			return prefixed
		}
	}
	
	public func adding<Tag>(`suffix`: String) -> Self
	where Message == DefaultMessage<Tag> {
		self.pullback { message in
			var suffixed = message
			suffixed.value = "\(suffixed.value)\(suffix)"
			return suffixed
		}
	}
}

extension Log {
	public static func console<Tag>() -> Log<DefaultMessage<Tag>>
	where Message == DefaultMessage<Tag> {
		Log<String>.print.pullback {
			$0.formatted
		}
	}
	
	public static func consoleLogErrors<Tag>() -> Log<DefaultMessage<Tag>>
	where Message == DefaultMessage<Tag> {
		self.console().minLevel(.error)
	}
}

import os

@available(iOS 14.0, macOS 11.0, *)
extension LogLevel {
	public var osLogType: OSLogType {
		switch self {
			case .info:
				return .info
			case .debug:
				return .debug
			case .warning:
				return .error
			case .error:
				return .error
			case .fatal:
				return .fault
		}
	}
}

@available(iOS 14.0, macOS 11.0, *)
extension Log {
	public static func logger<Tag>(
		subsystem: String = "",
		category: String = ""
	) -> Log<DefaultMessage<Tag>>
	where Message == DefaultMessage<Tag> {
		let logger = Logger(subsystem: subsystem, category: category)
		return Log<DefaultMessage<Tag>> { message in
			let tagsString = formatTags(message.tags)
			logger.log("\(message.value) \(tagsString)")
		}
	}
}

extension Log {
	public func addingTags<Tag>(
		_ tags: Tag...
	) -> Log<DefaultMessage<Tag>>
	where Message == DefaultMessage<Tag> {
		self.pullback { message in
			var withAddedTags = message
			withAddedTags.tags = Set(tags).union(withAddedTags.tags)
			return withAddedTags
		}
	}
}

extension Log {
	public func log<Tag>(
		_ value: Any,
		level: LogLevel,
		tags: Set<Tag>
	) where Message == DefaultMessage<Tag> {
		self.log(
			DefaultMessage(value: "\(value)", level: level, tags: tags)
		)
	}
	
	public func info<Tag>(
		_ value: Any,
		tags: Tag...
	) where Message == DefaultMessage<Tag> {
		self.log(value, level: .info, tags: Set(tags))
	}
	
	public func debug<Tag>(
		_ value: Any,
		tags: Tag...
	) where Message == DefaultMessage<Tag> {
		self.log(value, level: .debug, tags: Set(tags))
	}
	
	public func warning<Tag>(
		_ value: Any,
		tags: Tag...
	) where Message == DefaultMessage<Tag> {
		self.log(value, level: .warning, tags: Set(tags))
	}
	
	public func error<Tag>(
		_ value: Any,
		tags: Tag...
	) where Message == DefaultMessage<Tag> {
		self.log(value, level: .error, tags: Set(tags))
	}
	
	public func fatal<Tag>(
		_ value: Any,
		tags: Tag...
	) where Message == DefaultMessage<Tag> {
		self.log(value, level: .fatal, tags: Set(tags))
	}
}

extension Log {
	public func ignoreMessages<Tag>(
		where condition: @escaping (DefaultMessage<Tag>) -> Bool
	) -> Self
	where Message == DefaultMessage<Tag> {
		.init { message in
			guard condition(message) == false else {
				return
			}
			
			self.log(message)
		}
	}
	
	public func disable<Tag>(
		level: LogLevel
	) -> Self
	where Message == DefaultMessage<Tag> {
		self.ignoreMessages { message in
			message.level == level
		}
	}
	
	public func minLevel<Tag>(
		_ level: LogLevel
	) -> Self
	where Message == DefaultMessage<Tag> {
		self.ignoreMessages { message in
			message.level < level
		}
	}
	
	public func maxLevel<Tag>(
		_ level: LogLevel
	) -> Self
	where Message == DefaultMessage<Tag> {
		self.ignoreMessages { message in
			message.level > level
		}
	}
}

public typealias DefaultLog<Tag: Hashable> = Log<DefaultMessage<Tag>>
