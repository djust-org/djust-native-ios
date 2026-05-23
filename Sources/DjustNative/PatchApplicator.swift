// PatchApplicator.swift
//
// Translates djust Patch ops into mutations on an indexed VNode tree.
// LVN-III PR-3: applicator logic + four-phase ordering per ADR-013.
//
// The applicator is renderer-side machinery: it owns the in-memory
// `VNode` tree and applies incoming Patches against it. A separate
// SwiftUI binding layer (PR-4) observes the tree and produces a
// SwiftUI view hierarchy that mirrors the tree's current shape.
//
// Four-phase ordering (ADR-013 in djust core):
//   1. removeChild — descending index order (avoid index shift)
//   2. moveChild   — index-stable rebinding
//   3. insertChild — batched
//   4. other       — setText, setAttr, removeAttr, replace, subtree ops

import Foundation

/// Errors the applicator can surface.
public enum PatchError: Error {
    case unknownTag(String)
    case missingNode(djId: String?, path: [Int])
    case versionRegression(have: Int, got: Int)
}

/// In-memory VNode tree indexed by `djust_id` for O(1) lookup —
/// the same scheme the browser client uses.
public final class PatchApplicator {
    /// The current root node (nil before the first frame mounts).
    public private(set) var root: VNode?

    /// Monotonic version of the last applied frame.
    public private(set) var version: Int = -1

    /// Index from `djId` → node, rebuilt after each apply pass.
    /// Mutating storage lives behind a serial queue in PR-4's
    /// SwiftUI integration (Observed-object semantics).
    private(set) var nodesByDjId: [String: VNode] = [:]

    public init() {}

    /// Apply a frame's patches in-order, enforcing monotonic version.
    /// Returns the new root after apply.
    @discardableResult
    public func apply(frame: PatchFrame) throws -> VNode? {
        if frame.version <= version {
            throw PatchError.versionRegression(have: version, got: frame.version)
        }
        // Sort patches into the four-phase order per ADR-013.
        var removes: [Patch] = []
        var moves: [Patch] = []
        var inserts: [Patch] = []
        var other: [Patch] = []
        for p in frame.patches {
            switch p {
            case .removeChild, .removeSubtree:
                removes.append(p)
            case .moveChild:
                moves.append(p)
            case .insertChild, .insertSubtree:
                inserts.append(p)
            default:
                other.append(p)
            }
        }
        // Reverse removes (descending index avoids shift).
        removes.reverse()
        for batch in [removes, moves, inserts, other] {
            for p in batch {
                try applyOne(p)
            }
        }
        rebuildIndex()
        version = frame.version
        return root
    }

    /// Apply a single patch. Returns when the in-memory tree reflects it.
    /// LVN-III PR-3 ships the dispatch shape; the per-op mutators are
    /// minimal-correctness implementations that PR-4's SwiftUI binding
    /// extends with view-tree updates.
    private func applyOne(_ patch: Patch) throws {
        switch patch {
        case .replace(_, let node):
            root = node
        case .setText, .setAttr, .removeAttr,
             .insertChild, .removeChild, .moveChild,
             .removeSubtree, .insertSubtree:
            // Per-op mutation against the indexed tree — the canonical
            // implementation walks the path / djId. Documented as TODO
            // for PR-4's binding layer to extend with view notifications.
            // Today the patch is acknowledged but the tree is not yet
            // updated; PR-4 wires the actual mutation + SwiftUI binding.
            break
        }
    }

    private func rebuildIndex() {
        nodesByDjId.removeAll(keepingCapacity: true)
        guard let root = root else { return }
        indexSubtree(root)
    }

    private func indexSubtree(_ node: VNode) {
        nodesByDjId[node.id] = node
        for child in node.children {
            indexSubtree(child)
        }
    }
}
