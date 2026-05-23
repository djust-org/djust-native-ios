// Patch.swift
//
// Swift mirror of djust's Rust `Patch` enum + `VNode` struct
// (crates/djust_vdom/src/lib.rs:432-532). The wire format the server
// sends is identical for HTML and native targets — only the tag
// vocabulary inside `VNode` differs.
//
// LVN-III PR-2: type declarations matching the Python boundary
// (`(html, patches_json, version)` per `_rust.pyi:753`). Concrete
// patch-applicator logic that mutates a SwiftUI view tree lands in
// LVN-III PR-3.

import Foundation

/// A node in the server-side VDOM. The server emits widget-shaped
/// tag names (`"Stack"`, `"Text"`, ...) when `?platform=swiftui`;
/// see `WidgetTags.swift` for the v1 vocabulary.
public struct VNode: Codable, Equatable, Identifiable {
    /// Base62-encoded djust ID. Matches the Rust counter at
    /// `crates/djust_vdom/src/lib.rs:55-114`. The same ID space the
    /// browser client uses for `dj-id` DOM lookups.
    public let id: String

    /// Widget tag (e.g. `"Stack"`, `"Text"`). Must be in `widgetTags`
    /// for valid native renders — the applicator should fail loudly
    /// on an unknown tag (typo in template, vocabulary skew, etc.).
    public let tag: String

    /// Attribute map. Keys include `"dj-tap"` etc. for events and
    /// the v1 `styleAttrs` set for styling.
    public let attrs: [String: String]

    /// Text content for leaf nodes (e.g. `<Text>`). Empty for
    /// non-text widgets.
    public let text: String

    /// Children. Empty array for leaves.
    public let children: [VNode]
}

/// One mutation in the patch stream. Matches the Rust `Patch` enum.
/// Encoded as msgpack on the wire; decoded into this enum on receipt.
public enum Patch: Codable, Equatable {
    /// Replace the entire subtree at the given path.
    case replace(path: [Int], node: VNode)
    /// Update a leaf node's text content.
    case setText(path: [Int], djId: String?, text: String)
    /// Set or update an attribute on a node.
    case setAttr(path: [Int], djId: String?, key: String, value: String)
    /// Remove an attribute from a node.
    case removeAttr(path: [Int], djId: String?, key: String)
    /// Insert a child node at the given index, optionally after a sibling.
    case insertChild(path: [Int], djId: String?, refDjId: String?, node: VNode)
    /// Remove the child at the given index.
    case removeChild(path: [Int], djId: String?, index: Int)
    /// Move a child node from one position to another (preserves identity).
    case moveChild(path: [Int], djId: String?, fromIndex: Int, toIndex: Int)
    /// Remove an entire subtree (used by keyed `{% if %}` flips).
    case removeSubtree(path: [Int], djId: String?)
    /// Insert an entire subtree (paired with `removeSubtree`).
    case insertSubtree(path: [Int], djId: String?, node: VNode)
}

/// The frame shape `LiveViewConsumer` sends over the WebSocket.
/// `python/djust/websocket.py:~1078-1115`.
public struct PatchFrame: Codable, Equatable {
    /// One of `"patch"`, `"html_update"`, etc.
    public let type: String
    /// The patch stream — empty for initial-render frames.
    public let patches: [Patch]
    /// Monotonic version counter; the applicator should refuse
    /// out-of-order frames.
    public let version: Int
}
