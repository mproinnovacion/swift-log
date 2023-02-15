import XCTest
@testable import Log

final class LogTests: XCTestCase {
	func testString() throws {
		XCTAssertEqual(LogLevel.debug.string, "debug")
		XCTAssertEqual(LogLevel.info.string, "info")
		XCTAssertEqual(LogLevel.warning.string, "warning")
		XCTAssertEqual(LogLevel.error.string, "error")
		XCTAssertEqual(LogLevel.fatal.string, "fatal")
	}
	
	func testIgnoring() throws {
		var logs: [(String, LogLevel)] = []
		
		let log = Log { message, level in
			logs.append(("\(message)", level))
		}.ignoring(upTo: .warning)
		
		log.debug("debug")
		log.info("info")
		log.warning("warning")
		log.error("error")
		log.fatal("fatal")
			
		XCTAssert(logs[0] == ("error", .error))
		XCTAssert(logs[1] == ("fatal", .fatal))
	}
	
	func testAddPrefix() throws {
		var logs: [(String, LogLevel)] = []
		
		let log = Log { message, level in
			logs.append(("\(message)", level))
		}.adding(prefix: "prefix_")
		
		log.debug("debug")
		log.info("info")
		log.warning("warning")
		log.error("error")
		log.fatal("fatal")
			
		XCTAssert(logs[0] == ("prefix_debug", .debug))
		XCTAssert(logs[1] == ("prefix_info", .info))
		XCTAssert(logs[2] == ("prefix_warning", .warning))
		XCTAssert(logs[3] == ("prefix_error", .error))
		XCTAssert(logs[4] == ("prefix_fatal", .fatal))
	}
	
	func testAddSuffix() throws {
		var logs: [(String, LogLevel)] = []
		
		let log = Log { message, level in
			logs.append(("\(message)", level))
		}.adding(suffix: "_suffix")
		
		log.debug("debug")
		log.info("info")
		log.warning("warning")
		log.error("error")
		log.fatal("fatal")
			
		XCTAssert(logs[0] == ("debug_suffix", .debug))
		XCTAssert(logs[1] == ("info_suffix", .info))
		XCTAssert(logs[2] == ("warning_suffix", .warning))
		XCTAssert(logs[3] == ("error_suffix", .error))
		XCTAssert(logs[4] == ("fatal_suffix", .fatal))
	}
	
	func testConcat() throws {
		var logs: [(String, LogLevel)] = []
		var logs2: [(String, LogLevel)] = []

		let log = Log { message, level in
			logs.append(("\(message)", level))
		}.concat(
			with: Log { message, level in
				logs2.append(("\(message)", level))
			}
		)
		
		log.debug("debug")
		log.info("info")
		log.warning("warning")
		log.error("error")
		log.fatal("fatal")
			
		XCTAssert(logs[0] == ("debug", .debug))
		XCTAssert(logs[1] == ("info", .info))
		XCTAssert(logs[2] == ("warning", .warning))
		XCTAssert(logs[3] == ("error", .error))
		XCTAssert(logs[4] == ("fatal", .fatal))
		
		XCTAssert(logs2[0] == ("debug", .debug))
		XCTAssert(logs2[1] == ("info", .info))
		XCTAssert(logs2[2] == ("warning", .warning))
		XCTAssert(logs2[3] == ("error", .error))
		XCTAssert(logs2[4] == ("fatal", .fatal))
	}
	
	func testReduced() throws {
		var logs: [(String, LogLevel)] = []
		var logs2: [(String, LogLevel)] = []

		let log = [
			Log { message, level in
				logs.append(("\(message)", level))
			},
			Log { message, level in
				logs2.append(("\(message)", level))
			}
		].reduced
		
		log.debug("debug")
		log.info("info")
		log.warning("warning")
		log.error("error")
		log.fatal("fatal")
			
		XCTAssert(logs[0] == ("debug", .debug))
		XCTAssert(logs[1] == ("info", .info))
		XCTAssert(logs[2] == ("warning", .warning))
		XCTAssert(logs[3] == ("error", .error))
		XCTAssert(logs[4] == ("fatal", .fatal))
		
		XCTAssert(logs2[0] == ("debug", .debug))
		XCTAssert(logs2[1] == ("info", .info))
		XCTAssert(logs2[2] == ("warning", .warning))
		XCTAssert(logs2[3] == ("error", .error))
		XCTAssert(logs2[4] == ("fatal", .fatal))
	}
}
