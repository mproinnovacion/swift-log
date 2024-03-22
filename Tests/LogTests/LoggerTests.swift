import XCTest
@testable import Log

final class LoggerTests: XCTestCase {
	func testType() {
		XCTAssertEqual(
			LogLevel.debug.osLogType,
			.debug
		)
		
		XCTAssertEqual(
			LogLevel.info.osLogType,
			.info
		)
		
		XCTAssertEqual(
			LogLevel.warning.osLogType,
			.error
		)
		
		XCTAssertEqual(
			LogLevel.error.osLogType,
			.error
		)
		
		XCTAssertEqual(
			LogLevel.fatal.osLogType,
			.fault
		)
	}
}
