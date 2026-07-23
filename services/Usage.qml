pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    // Written every turn by the Claude Code statusline; a fork-local convenience source
    property int fiveHourPct: 0
    property int sevenDayPct: 0
    property double fiveHourReset: 0
    property double sevenDayReset: 0
    property bool valid: false

    function load(data: string): void {
        let d;
        try {
            d = JSON.parse(data);
        } catch (e) {
            return;
        }
        const rl = d.rate_limits;
        if (!rl)
            return;
        root.fiveHourPct = Math.round(rl.five_hour?.used_percentage ?? 0);
        root.sevenDayPct = Math.round(rl.seven_day?.used_percentage ?? 0);
        root.fiveHourReset = rl.five_hour?.resets_at ?? 0;
        root.sevenDayReset = rl.seven_day?.resets_at ?? 0;
        root.valid = true;
    }

    FileView {
        path: `${Paths.home}/.claude/usage-snapshot.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.valid = false;
        }
    }
}
