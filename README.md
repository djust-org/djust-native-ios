# djust-native-ios

Native iOS (SwiftUI) client for [djust LiveView](https://github.com/djust-org/djust).

**Status**: Scaffold only — implementation tracked in
[djust-org/djust#1579 (LVN-III)](https://github.com/djust-org/djust/issues/1579).
This repo currently contains `LICENSE` + this README; the SwiftPM
`Package.swift`, source, tests, and CI all land via that issue's PR
sequence.

## What this is

djust ships a server-side reactive framework (Django + Rust VDOM). The
default client is HTML in a browser — `client.js` consumes a stream of
VDOM patches over WebSocket and applies them to the DOM. This repo will
ship a parallel client: subscribe to the same WebSocket, consume the
same patch stream, render true SwiftUI widgets instead of HTML.

The pattern is borrowed from
[Phoenix LiveView Native](https://github.com/liveview-native/live_view_native).
djust's specific design lives in
[ADR-019: LiveView Native](https://github.com/djust-org/djust/blob/main/docs/adr/019-liveview-native.md).

## Eventual public API

```swift
import DjustNative

struct ContentView: View {
    var body: some View {
        DjustLiveView(url: URL(string: "ws://127.0.0.1:8111/ws/live/")!)
    }
}
```

`DjustLiveView` returns a SwiftUI `some View`. URL connection, msgpack
decoding, the four-phase patch applicator (Remove → Move → Insert →
other, per
[ADR-013](https://github.com/djust-org/djust/blob/main/docs/adr/013-view-transitions-api-integration.md)),
event sending, and reconnect/sticky semantics (per
[ADRs 011 / 014 / 018](https://github.com/djust-org/djust/blob/main/docs/adr/))
all live behind the single view.

## Companion repos

| Repo | Purpose |
| - | - |
| [`djust-org/djust`](https://github.com/djust-org/djust) | The framework. Server-side reactive Python + Rust VDOM. |
| [`djust-org/djust-native-android`](https://github.com/djust-org/djust-native-android) | Android equivalent (Jetpack Compose). Same protocol, different platform. |
| [`djust-org/djust-mobile-toga`](https://github.com/djust-org/djust-mobile-toga) | WebView mode — reuse web templates verbatim inside a Toga `WebView`. The "easy mode" alongside this repo's "polish mode." |

## License

[MIT](LICENSE) — matches djust.
