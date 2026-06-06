pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import qs.utils

Singleton {
    id: root

    property var events: ({})
    property bool loaded: false

    readonly property string storagePath: `${Paths.state}/calendar-events.json`

    function key(date: var): string {
        const d = new Date(date);
        const year = d.getUTCFullYear();
        const month = String(d.getUTCMonth() + 1).padStart(2, "0");
        const day = String(d.getUTCDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
    }

    function listFor(date: var): var {
        return events[key(date)] ?? [];
    }

    function hasEvents(date: var): bool {
        return listFor(date).length > 0;
    }

    function addEvent(date: var, title: string): void {
        const cleanTitle = title.trim();
        if (!cleanTitle)
            return;

        const dateKey = key(date);
        const nextEvents = JSON.parse(JSON.stringify(events));
        if (!nextEvents[dateKey])
            nextEvents[dateKey] = [];

        nextEvents[dateKey].push({
            title: cleanTitle,
            createdAt: Date.now()
        });
        events = nextEvents;
        save();
    }

    function removeEvent(date: var, index: int): void {
        const dateKey = key(date);
        const dayEvents = events[dateKey] ?? [];
        if (index < 0 || index >= dayEvents.length)
            return;

        const nextEvents = JSON.parse(JSON.stringify(events));
        nextEvents[dateKey].splice(index, 1);
        if (nextEvents[dateKey].length === 0)
            delete nextEvents[dateKey];

        events = nextEvents;
        save();
    }

    function updateEvent(date: var, index: int, title: string): void {
        const cleanTitle = title.trim();
        if (!cleanTitle)
            return;

        const dateKey = key(date);
        const dayEvents = events[dateKey] ?? [];
        if (index < 0 || index >= dayEvents.length)
            return;

        const nextEvents = JSON.parse(JSON.stringify(events));
        const current = nextEvents[dateKey][index];
        nextEvents[dateKey][index] = {
            title: cleanTitle,
            createdAt: current.createdAt ?? Date.now(),
            updatedAt: Date.now()
        };

        events = nextEvents;
        save();
    }

    function save(): void {
        storage.setText(JSON.stringify(events));
    }

    function load(): void {
        try {
            events = JSON.parse(storage.text() || "{}");
        } catch (e) {
            events = {};
        }
    }

    FileView {
        id: storage

        path: root.storagePath
        printErrors: false

        onLoaded: {
            root.load();
            root.loaded = true;
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.events = {};
                root.loaded = true;
                Qt.callLater(() => storage.setText("{}"));
            }
        }
    }
}
