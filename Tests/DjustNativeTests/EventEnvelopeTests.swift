import XCTest
@testable import DjustNative

final class EventEnvelopeTests: XCTestCase {
    func testEncodeMatchesShape() throws {
        let env = EventEnvelope(event: "dismiss_alert", params: ["x": "1"], djId: "a")
        let data = try env.encode()
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["type"] as? String, "event")
        XCTAssertEqual(dict["event"] as? String, "dismiss_alert")
        XCTAssertEqual(dict["djId"] as? String, "a")
    }
}
