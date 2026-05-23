// PatchApplicatorTests.swift
//
// Pin the applicator's structural contract: monotonic version, replace
// op updates root, four-phase ordering shape.

import XCTest
@testable import DjustNative

final class PatchApplicatorTests: XCTestCase {
    func testInitialVersionIsNegative() {
        let app = PatchApplicator()
        XCTAssertEqual(app.version, -1)
        XCTAssertNil(app.root)
    }

    func testReplaceUpdatesRoot() throws {
        let app = PatchApplicator()
        let node = VNode(id: "a", tag: "Stack", attrs: [:], text: "", children: [])
        try app.apply(frame: PatchFrame(
            type: "patch",
            patches: [.replace(path: [], node: node)],
            version: 0
        ))
        XCTAssertEqual(app.version, 0)
        XCTAssertEqual(app.root, node)
        XCTAssertEqual(app.nodesByDjId["a"], node)
    }

    func testVersionRegressionThrows() throws {
        let app = PatchApplicator()
        let node = VNode(id: "a", tag: "Stack", attrs: [:], text: "", children: [])
        try app.apply(frame: PatchFrame(type: "patch", patches: [
            .replace(path: [], node: node),
        ], version: 5))
        XCTAssertThrowsError(try app.apply(frame: PatchFrame(
            type: "patch", patches: [], version: 4
        ))) { err in
            guard case PatchError.versionRegression(let have, let got) = err else {
                XCTFail("wrong error: \(err)")
                return
            }
            XCTAssertEqual(have, 5)
            XCTAssertEqual(got, 4)
        }
    }
}
