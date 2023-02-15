#  Usage

You can use Log implementations as provided, but it's recommended that you create some tags so that it's easier to filter the console messages by error category:

```
enum LogTag {
	case persistence
	case network
	...
}

extension Log {
	static func format(
		_ message: String,
		tags: [LogTag]
	) -> String {
		let tagsString = tags.map { "#\($0)" }.joined(separator: " ")
		
		return [
			message,
			tagsString.isEmpty ? nil : tagsString
		]
		.compact()
		.joined(separator: " ")
	}
	
	public func log(_ object: Any, level: LogLevel, tags: [LogTag]) {
		self.format(string, level: level, tags: tags)
	}
	
	public func info(
		_ message: String,
		tags: LogTag...
	) {
		self.log(message, level: .info, tags: tags)
	}
	
	public func debug(
		_ message: String,
		tags: LogTag...
	) {
		self.log(message, level: .debug, tags: tags)
	}
	
	public func warning(
		_ message: String,
		tags: LogTag...
	) {
		self.log(message, level: .warning, tags: tags)
	}
	
	public func error(
		_ message: String,
		tags: LogTag...
	) {
		self.log(message, level: .error, tags: tags)
	}
	
	public func fatal(
		_ message: String,
		tags: LogTag...
	) {
		self.log(message, level: .fatal, tags: tags)
	}
}

```

Then you can use it in this way:

```
log.debug("A simple message", tags: .network, .persistence)
```
