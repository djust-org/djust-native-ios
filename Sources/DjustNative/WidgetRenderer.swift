// WidgetRenderer.swift
//
// LVN-III PR-4: SwiftUI view that renders a VNode into the
// corresponding widget per the v1 vocabulary (`widgetTags`). Each
// tag → SwiftUI mapping follows the table in
// docs/native-widget-vocabulary.md (in djust-org/djust).
//
// This is the visual layer. PatchApplicator (PR-3) owns the in-memory
// tree; this view observes a node and produces its SwiftUI counterpart.
// Recursive: child VNodes are rendered by recursive `WidgetRenderer`
// invocations.

import SwiftUI

/// Render a single VNode as its SwiftUI counterpart.
public struct WidgetRenderer: View {
    public let node: VNode

    /// Event callback — fires for `dj-tap`, `dj-change`, `dj-input`.
    /// Wired to `WebSocketClient.sendEvent` in `DjustLiveView` (PR-6).
    public let onEvent: (_ name: String, _ params: [String: String]) -> Void

    public init(
        node: VNode,
        onEvent: @escaping (_ name: String, _ params: [String: String]) -> Void = { _, _ in }
    ) {
        self.node = node
        self.onEvent = onEvent
    }

    public var body: some View {
        widgetBody
    }

    @ViewBuilder
    private var widgetBody: some View {
        switch node.tag {
        case "Stack":
            VStack { childViews }
        case "HStack":
            HStack { childViews }
        case "ZStack":
            ZStack { childViews }
        case "Text":
            Text(node.text)
        case "Button":
            Button(action: { fireTap() }) { childViews }
        case "TextField":
            TextField(node.attrs["placeholder"] ?? "", text: .constant(node.text))
        case "Toggle":
            Toggle(node.text, isOn: .constant(node.attrs["isOn"] == "true"))
        case "List":
            List { childViews }
        case "Image":
            Image(systemName: node.attrs["systemName"] ?? "questionmark")
        case "ScrollView":
            ScrollView { childViews }
        case "Spacer":
            Spacer()
        case "NavigationView":
            NavigationView { childViews }
        default:
            // Unknown tag — surface visibly so author catches the typo.
            Text("⚠ unknown widget: \(node.tag)")
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    private var childViews: some View {
        ForEach(node.children) { child in
            WidgetRenderer(node: child, onEvent: onEvent)
        }
    }

    private func fireTap() {
        if let handler = node.attrs["dj-tap"] {
            onEvent(handler, [:])
        }
    }
}
