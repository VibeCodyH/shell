pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property list<var> items: []
    property string generatedAt: ""
    property var hidden: ({})

    readonly property list<var> visibleItems: items.filter(i => !root.hidden[i.id])

    // Optimistic hide: drop the row the moment it's cleared; the producer
    // re-mirror (dismiss.mjs) then makes it permanent.
    function dismiss(id: string): void {
        const h = Object.assign({}, root.hidden);
        h[id] = true;
        root.hidden = h;
    }

    function load(data: string): void {
        let d;
        try {
            d = JSON.parse(data);
        } catch (e) {
            return; // Keep the last valid queue through a producer's partial write
        }
        if (d.version !== 1 || !Array.isArray(d.items))
            return;
        root.items = d.items;
        root.generatedAt = d.generatedAt ?? "";
    }

    FileView {
        path: `${Paths.state}/triage.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.items = [];
        }
    }
}
