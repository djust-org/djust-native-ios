// WidgetTags.swift
//
// Mirror of djust-org/djust's `python/djust/renderers/widgets.py` —
// the frozen v1 widget vocabulary (12 widgets, SwiftUI ∩ Compose
// intersection). Authoritative source is the Python module; this
// Swift constant must move in lockstep with it (see ADR-019 §SemVer).
//
// LVN-III PR-1 (djust-org/djust#1579): vocabulary mirror. PR-2 onward
// adds widget-renderer functions that map each tag to a SwiftUI view.
//
// See:
//   - https://github.com/djust-org/djust/blob/main/docs/adr/019-liveview-native.md
//   - https://github.com/djust-org/djust/blob/main/docs/native-widget-vocabulary.md
//   - https://github.com/djust-org/djust/blob/main/python/djust/renderers/widgets.py

import Foundation

/// The frozen v1 widget vocabulary. Mirrors `WIDGET_TAGS` in the
/// djust Python package. A `NativeRenderer`-emitted VNode whose tag
/// is not in this set is a bug — the client should fail loudly so the
/// author catches the typo early.
public let widgetTags: Set<String> = [
    // Layout containers
    "Stack",          // → SwiftUI VStack
    "HStack",         // → SwiftUI HStack
    "ZStack",         // → SwiftUI ZStack
    // Leaf widgets
    "Text",           // → SwiftUI Text
    "Button",         // → SwiftUI Button
    "TextField",      // → SwiftUI TextField
    "Toggle",         // → SwiftUI Toggle
    "List",           // → SwiftUI List
    "Image",          // → SwiftUI Image
    // Layout helpers
    "ScrollView",     // → SwiftUI ScrollView
    "Spacer",         // → SwiftUI Spacer
    "NavigationView", // → SwiftUI NavigationView
]

/// Event-handler attribute names a native template uses. Mirror of
/// the djust Python `EVENT_ATTRS` frozenset.
public let eventAttrs: Set<String> = [
    "dj-tap",
    "dj-change",
    "dj-input",
]

/// Style attribute names this client honors in v1. Mirror of the
/// djust Python `STYLE_ATTRS` frozenset.
public let styleAttrs: Set<String> = [
    "padding",
    "spacing",
    "alignment",
    "foregroundColor",
    "font",
]

/// True iff `tag` is in the frozen v1 widget vocabulary.
public func isWidgetTag(_ tag: String) -> Bool {
    widgetTags.contains(tag)
}
