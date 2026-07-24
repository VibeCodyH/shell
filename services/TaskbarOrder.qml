pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.utils

// Single source of truth for taskbar ordering, shared by every monitor's bar (so they never
// drift and only one file is written). Two layers:
//   • order      — per-window order as {address, appClass} pairs; persisted so the exact
//                  arrangement survives a shell reload (windows keep their addresses while
//                  Hyprland lives). A pair only matches when address AND class agree, so a
//                  recycled address after reboot can't drag a stranger into the wrong slot.
//   • classOrder — order keyed by app class; the fallback after a reboot invalidates every
//                  address. Duplicate classes (e.g. two Brave windows) collapse to one slot
//                  there and fall back to Hyprland order as a tiebreak.
Singleton {
    id: root

    property var order: []
    property var classOrder: []
    property string draggingAddress: ""
    property bool loaded: false

    // Sort key for one window. Windows with a surviving {address, class} pair key on that exact
    // slot; everything else keys on its class's persisted rank, then Hyprland order. Address
    // ranks occupy [0, order.length) and class ranks start at order.length, so the two never
    // collide and there are no ties (hyprIndex is unique).
    function rank(address: string, appClass: string, hyprIndex: int): real {
        const ai = root.order.findIndex(e => e.address === address && e.appClass === appClass);
        if (ai !== -1)
            return ai;

        const base = root.order.length;
        const ci = root.classOrder.indexOf(appClass);
        const slot = ci !== -1 ? ci : root.classOrder.length; // unknown class → after known ones
        return base + slot * 1e6 + hyprIndex;
    }

    // The canonical taskbar order. BOTH the bar icons and the hover-preview popouts must sort
    // through this same function, or icon N and preview N point at different windows. Rank each
    // window once against its STABLE index `i` (ranking inside the comparator reads a half-sorted
    // array), then sort by that.
    function sorted(tops: var): var {
        // Drop phantom entries: Hyprland IPC can miss closewindow events under rapid window
        // churn (Steam game launches), and quickshell's refreshToplevels() never prunes — so
        // dead HyprlandToplevels linger forever. The wayland foreign-toplevel handle is
        // compositor-authoritative: it's nulled on destroy, and reading the live handle list
        // here makes callers' bindings re-filter whenever any real window opens or closes.
        const live = ToplevelManager.toplevels.values;
        const keyed = [...tops].filter(t => live.includes(t?.wayland)).map((t, i) => ({
                    t,
                    r: root.rank(t?.lastIpcObject?.address ?? "", t?.lastIpcObject?.class ?? "", i)
                }));
        keyed.sort((a, b) => a.r - b.r);
        return keyed.map(k => k.t);
    }

    // Commit a full display order (list of {address, appClass}). Updates the per-window pair
    // order and rebuilds the first-wins-deduped class order; both persist.
    function commit(entries: var): void {
        root.order = entries.filter(e => e.address);

        const seen = [];
        for (const e of entries)
            if (e.appClass && !seen.includes(e.appClass))
                seen.push(e.appClass);
        root.classOrder = seen;
    }

    // Relocate `address` to `toIndex` within the current display `entries`, then commit.
    function moveItem(entries: var, address: string, toIndex: int): void {
        if (!address || toIndex < 0 || toIndex >= entries.length)
            return;

        const from = entries.findIndex(e => e.address === address);
        if (from === -1 || from === toIndex)
            return;

        const copy = entries.slice();
        const moved = copy.splice(from, 1)[0];
        copy.splice(toIndex, 0, moved);
        root.commit(copy);
    }

    onOrderChanged: {
        if (root.loaded)
            saveTimer.restart();
    }

    onClassOrderChanged: {
        if (root.loaded)
            saveTimer.restart();
    }

    Timer {
        id: saveTimer

        interval: 500
        onTriggered: storage.setText(JSON.stringify({
            version: 2,
            order: root.order,
            classOrder: root.classOrder
        }))
    }

    FileView {
        id: storage

        path: `${Paths.state}/taskbar-order.json`
        printErrors: false
        onLoaded: {
            try {
                const d = JSON.parse(text());
                if (Array.isArray(d?.classOrder))
                    root.classOrder = d.classOrder; // v1 files carry this too
                if (d?.version === 2 && Array.isArray(d.order))
                    root.order = d.order.filter(e => typeof e?.address === "string" && typeof e?.appClass === "string");
            } catch (e) {
                // Corrupt file — start clean rather than crash.
            }
            root.loaded = true;
        }
        onLoadFailed: err => {
            root.loaded = true;
            if (err === FileViewError.FileNotFound)
                Qt.callLater(() => setText(JSON.stringify({
                    version: 2,
                    order: [],
                    classOrder: []
                })));
        }
    }
}
