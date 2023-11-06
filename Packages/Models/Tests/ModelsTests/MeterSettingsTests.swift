import XCTest

@testable import Models

final class MeterSettingsTests: XCTestCase {

    func testMeterTimeSeconds() throws {
        XCTAssertEqual(25200, MeterSettings.MeterTime(hour: 7, minute: 0).seconds)
        XCTAssertEqual(68400, MeterSettings.MeterTime(hour: 19, minute: 0).seconds)
    }
}
