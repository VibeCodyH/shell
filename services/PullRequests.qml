pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property list<var> prs: []
    property string generatedAt: ""

    function load(data: string): void {
        let d;
        try {
            d = JSON.parse(data);
        } catch (e) {
            return; // Keep the last valid queue through a producer's partial write
        }
        if (d.version !== 1 || !Array.isArray(d.prs))
            return;
        root.prs = d.prs;
        root.generatedAt = d.generatedAt ?? "";
    }

    FileView {
        path: `${Paths.state}/prs.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.prs = [];
        }
    }
}
