import XCTest
@testable import Log

final class LogTests: XCTestCase {
	enum LogTag: String {
		case tests
		case other
	}
	
	func testString() throws {
		XCTAssertEqual(LogLevel.debug.formatted, "🔎 debug")
		XCTAssertEqual(LogLevel.info.formatted, "ℹ️ info")
		XCTAssertEqual(LogLevel.warning.formatted, "⚠️ warning")
		XCTAssertEqual(LogLevel.error.formatted, "🚫 error")
		XCTAssertEqual(LogLevel.fatal.formatted, "💀 fatal")
	}
	
	func testMinLevel() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.minLevel(.error)
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "error", level: .error, tags: [.tests]),
				.init(value: "fatal", level: .fatal, tags: [.tests])
			]
		)
	}
	
	func testMaxLevel() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.maxLevel(.warning)
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "debug", level: .debug, tags: [.tests]),
				.init(value: "info", level: .info, tags: [.tests]),
				.init(value: "warning", level: .warning, tags: [.tests])
			]
		)
	}
	
	func testAddPrefix() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.adding(prefix: "prefix_")
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "prefix_debug", level: .debug, tags: [.tests]),
				.init(value: "prefix_info", level: .info, tags: [.tests]),
				.init(value: "prefix_warning", level: .warning, tags: [.tests]),
				.init(value: "prefix_error", level: .error, tags: [.tests]),
				.init(value: "prefix_fatal", level: .fatal, tags: [.tests])
			]
		)
	}
	
	func testAddPrefixString() throws {
		var messages: [String] = []
		
		let log = Log<String> { message in
			messages.append(message)
		}.adding(prefix: "prefix_")
		
		log.log("debug")
		log.log("info")
		log.log("warning")
		log.log("error")
		log.log("fatal")
		
		XCTAssertEqual(
			messages,
			[
				"prefix_debug",
				"prefix_info",
				"prefix_warning",
				"prefix_error",
				"prefix_fatal"
			]
		)
	}
	
	func testAddSuffix() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.adding(suffix: "_suffix")
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "debug_suffix", level: .debug, tags: [.tests]),
				.init(value: "info_suffix", level: .info, tags: [.tests]),
				.init(value: "warning_suffix", level: .warning, tags: [.tests]),
				.init(value: "error_suffix", level: .error, tags: [.tests]),
				.init(value: "fatal_suffix", level: .fatal, tags: [.tests])
			]
		)
	}
	
	func testAddSuffixString() throws {
		var messages: [String] = []
		
		let log = Log<String> { message in
			messages.append(message)
		}.adding(suffix: "_suffix")
		
		log.log("debug")
		log.log("info")
		log.log("warning")
		log.log("error")
		log.log("fatal")
		
		XCTAssertEqual(
			messages,
			[
				"debug_suffix",
				"info_suffix",
				"warning_suffix",
				"error_suffix",
				"fatal_suffix"
			]
		)
	}
	
	func testCombined() throws {
		var messages1: [DefaultMessage<LogTag>] = []
		var messages2: [DefaultMessage<LogTag>] = []
		
		let log1 = DefaultLog<LogTag> { message in
			messages1.append(message)
		}
		
		let log2 = DefaultLog<LogTag> { message in
			messages2.append(message)
		}
		
		let log = log1.combined(with: log2)
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages1,
			[
				.init(value: "debug", level: .debug, tags: [.tests]),
				.init(value: "info", level: .info, tags: [.tests]),
				.init(value: "warning", level: .warning, tags: [.tests]),
				.init(value: "error", level: .error, tags: [.tests]),
				.init(value: "fatal", level: .fatal, tags: [.tests])
			]
		)
		
		XCTAssertEqual(
			messages2,
			[
				.init(value: "debug", level: .debug, tags: [.tests]),
				.init(value: "info", level: .info, tags: [.tests]),
				.init(value: "warning", level: .warning, tags: [.tests]),
				.init(value: "error", level: .error, tags: [.tests]),
				.init(value: "fatal", level: .fatal, tags: [.tests])
			]
		)
	}
	
	func testReduced() throws {
		var messages1: [DefaultMessage<LogTag>] = []
		var messages2: [DefaultMessage<LogTag>] = []
		
		let log1 = DefaultLog<LogTag> { message in
			messages1.append(message)
		}
		
		let log2 = DefaultLog<LogTag> { message in
			messages2.append(message)
		}
		
		let log = [log1, log2].reduced()
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages1,
			[
				.init(value: "debug", level: .debug, tags: [.tests]),
				.init(value: "info", level: .info, tags: [.tests]),
				.init(value: "warning", level: .warning, tags: [.tests]),
				.init(value: "error", level: .error, tags: [.tests]),
				.init(value: "fatal", level: .fatal, tags: [.tests])
			]
		)
		
		XCTAssertEqual(
			messages2,
			[
				.init(value: "debug", level: .debug, tags: [.tests]),
				.init(value: "info", level: .info, tags: [.tests]),
				.init(value: "warning", level: .warning, tags: [.tests]),
				.init(value: "error", level: .error, tags: [.tests]),
				.init(value: "fatal", level: .fatal, tags: [.tests])
			]
		)
	}
	
	func testAddingTags() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.addingTags(.other)
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "debug", level: .debug, tags: [.other, .tests]),
				.init(value: "info", level: .info, tags: [.other, .tests]),
				.init(value: "warning", level: .warning, tags: [.other, .tests]),
				.init(value: "error", level: .error, tags: [.other, .tests]),
				.init(value: "fatal", level: .fatal, tags: [.other, .tests])
			]
		)
	}
	
	func testMaxLengthString() throws {
		var messages: [String] = []
		
		let log = Log<String> { message in
			messages.append(message)
		}.maxLength(1)

		log.log("debug")
		log.log("info")
		log.log("warning")
		log.log("error")
		log.log("fatal")
		
		XCTAssertEqual(
			messages,
			[
				"d",
				"i",
				"w",
				"e",
				"f"
			]
		)
	}
	
	func testMaxLength() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.maxLength(1)
		
		log.debug("debug", tags: .tests)
		log.info("info", tags: .tests)
		log.warning("warning", tags: .tests)
		log.error("error", tags: .tests)
		log.fatal("fatal", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "d", level: .debug, tags: [.tests]),
				.init(value: "i", level: .info, tags: [.tests]),
				.init(value: "w", level: .warning, tags: [.tests]),
				.init(value: "e", level: .error, tags: [.tests]),
				.init(value: "f", level: .fatal, tags: [.tests])
			]
		)
	}
	
	func testMaxLines() throws {
		var messages: [DefaultMessage<LogTag>] = []
		
		let log = DefaultLog<LogTag> { message in
			messages.append(message)
		}.maxLines(1)
		
		log.debug("debug\nsecond", tags: .tests)
		log.info("info\nsecond", tags: .tests)
		log.warning("warning\nsecond", tags: .tests)
		log.error("error\nsecond", tags: .tests)
		log.fatal("fatal\nsecond", tags: .tests)
		
		XCTAssertEqual(
			messages,
			[
				.init(value: "debug", level: .debug, tags: [.tests]),
				.init(value: "info", level: .info, tags: [.tests]),
				.init(value: "warning", level: .warning, tags: [.tests]),
				.init(value: "error", level: .error, tags: [.tests]),
				.init(value: "fatal", level: .fatal, tags: [.tests])
			]
		)
	}
}
