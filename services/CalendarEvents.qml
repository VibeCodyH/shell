pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    readonly property string path: Config.dashboard.calendar.eventsFile || `${Paths.state}/calendar-events.json`
    property list<var> events: []

    function parseDate(value: string): var {
        // Date-only values are local midnight; a bare UTC parse would shift the day across the offset
        if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
            const parts = value.split("-");
            return new Date(parts[0], parts[1] - 1, parts[2]);
        }
        return new Date(value);
    }

    function load(text: string): void {
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            return; // Keep the last valid list through a producer's partial write
        }
        if (data.version !== 1 || !Array.isArray(data.events))
            return;

        const parsed = [];
        for (const e of data.events) {
            if (!e.id || !e.title || !e.start)
                continue;
            const start = parseDate(e.start);
            const end = e.end ? parseDate(e.end) : start;
            if (isNaN(start.getTime()) || end < start)
                continue;
            parsed.push({
                id: e.id,
                title: e.title,
                start,
                end,
                allDay: e.allDay ?? false,
                location: e.location ?? "",
                url: e.url ?? "",
                color: e.color ?? ""
            });
        }
        parsed.sort((a, b) => a.start - b.start);
        root.events = parsed;
    }

    function eventsForDate(date: date): list<var> {
        return events.filter(e => e.start.getFullYear() === date.getFullYear() && e.start.getMonth() === date.getMonth() && e.start.getDate() === date.getDate());
    }

    function hasEvents(date: date): bool {
        return events.some(e => e.start.getFullYear() === date.getFullYear() && e.start.getMonth() === date.getMonth() && e.start.getDate() === date.getDate());
    }

    FileView {
        path: root.path
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.events = [];
        }
    }
}
