pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property list<var> tasks: []
    property string generatedAt: ""
    property var hidden: ({})

    readonly property list<var> visibleTasks: tasks.filter(t => !root.hidden[t.id])

    function load(data: string): void {
        let d;
        try {
            d = JSON.parse(data);
        } catch (e) {
            return; // Keep the last valid list through a producer's partial write
        }
        if (d.version !== 1 || !Array.isArray(d.tasks))
            return;
        root.tasks = d.tasks;
        root.generatedAt = d.generatedAt ?? "";
    }

    // Optimistic hide: Graph is not read-after-write consistent, so drop the row
    // locally the moment it's cleared; the producer re-mirror then confirms it.
    function dismiss(id: string): void {
        const h = Object.assign({}, root.hidden);
        h[id] = true;
        root.hidden = h;
    }

    FileView {
        path: `${Paths.state}/tasks.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.tasks = [];
        }
    }
}
