// WidgetTagsTests.swift
//
// Pin the v1 vocabulary mirror against the Python source of truth in
// djust-org/djust. If Python's WIDGET_TAGS adds/removes entries, this
// test fails and forces the Swift mirror to update.

import XCTest
@testable import DjustNative

final class WidgetTagsTests: XCTestCase {
    func testWidgetVocabularyIsExactlyTwelve() {
        XCTAssertEqual(widgetTags.count, 12)
    }

    func testWidgetVocabularyMirrorsPythonSource() {
        let expected: Set<String> = [
            "Stack", "HStack", "ZStack",
            "Text", "Button", "TextField", "Toggle", "List", "Image",
            "ScrollView", "Spacer", "NavigationView",
        ]
        XCTAssertEqual(widgetTags, expected)
    }

    func testEventAttrsMirrorPythonSource() {
        XCTAssertEqual(eventAttrs, ["dj-tap", "dj-change", "dj-input"])
    }

    func testStyleAttrsMirrorPythonSource() {
        XCTAssertEqual(
            styleAttrs,
            ["padding", "spacing", "alignment", "foregroundColor", "font"]
        )
    }

    func testIsWidgetTag() {
        XCTAssertTrue(isWidgetTag("Stack"))
        XCTAssertTrue(isWidgetTag("Button"))
        XCTAssertFalse(isWidgetTag("div"))
        XCTAssertFalse(isWidgetTag(""))
    }
}
