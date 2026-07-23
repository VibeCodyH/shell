pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property string text: ""
    property string generatedAt: ""
    property int count: 0
    property int calendarCount: 0
    property int fires: 0
    property int teams: 0
    property int github: 0
    property list<var> rows: []

    function load(data: string): void {
        let d;
        try {
            d = JSON.parse(data);
        } catch (e) {
            return; // Keep the last valid brief through a producer's partial write
        }
        root.text = d.text ?? "";
        root.generatedAt = d.generatedAt ?? "";
        root.count = d.count ?? 0;
        root.calendarCount = d.calendarCount ?? 0;
        root.fires = d.bySource?.fires ?? 0;
        root.teams = d.bySource?.teams ?? 0;
        root.github = d.bySource?.github ?? 0;
        root.rows = d.rows ?? [];
    }

    FileView {
        path: `${Paths.state}/brief.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.rows = [];
        }
    }
}
