// WebSocketClientTests.swift
//
// LVN-III PR-2: pin the URL-construction and Platform-enum behavior.
// The msgpack decode + receive loop are stubs in this PR (tested
// in PR-3 once the decoder lands).

import XCTest
@testable import DjustNative

final class WebSocketClientTests: XCTestCase {
    func testPlatformRawValues() {
        XCTAssertEqual(WebSocketClient.Platform.swiftui.rawValue, "swiftui")
        XCTAssertEqual(WebSocketClient.Platform.compose.rawValue, "compose")
    }

    func testConnectionURLAppendsPlatform() throws {
        let base = URL(string: "ws://127.0.0.1:8111/ws/live/")!
        let client = WebSocketClient(url: base, platform: .swiftui)
        let url = client.connectionURL
        XCTAssertTrue(url.absoluteString.contains("platform=swiftui"),
                      "expected ?platform=swiftui, got \(url.absoluteString)")
    }

    func testConnectionURLPreservesExistingQueryItems() throws {
        let base = URL(string: "ws://127.0.0.1:8111/ws/live/?session=abc")!
        let client = WebSocketClient(url: base, platform: .swiftui)
        let s = client.connectionURL.absoluteString
        XCTAssertTrue(s.contains("session=abc"))
        XCTAssertTrue(s.contains("platform=swiftui"))
    }

    func testFramesStreamRaisesDecoderUnimplementedUntilPR3() async throws {
        let client = WebSocketClient(
            url: URL(string: "ws://127.0.0.1:8111/ws/live/")!
        )
        do {
            for try await _ in client.frames() {
                XCTFail("stream should fail until decoder ships in PR-3")
            }
            XCTFail("stream should have thrown")
        } catch DjustWSError.decoderUnimplemented {
            // expected — pinned by this test until PR-3
        }
    }
}
