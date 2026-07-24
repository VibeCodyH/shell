pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// KDE Connect phone state + quick actions for the bar phone popout (fork-only).
// Battery reads go through gdbus since kdeconnect-cli has no battery query.
Singleton {
    id: root

    readonly property bool online: deviceId.length > 0
    property string deviceId: ""
    property int charge: -1
    property bool charging: false

    function sendClipboard(): void {
        Quickshell.execDetached(["sh", "-c", `kdeconnect-cli -d ${deviceId} --share-text "$(wl-paste -n)"`]);
    }

    function shareFile(): void {
        Quickshell.execDetached(["sh", "-c", `f=$(kdialog --getopenfilename "$HOME"); [ -n "$f" ] && kdeconnect-cli -d ${deviceId} --share "$f"`]);
    }

    function openMessages(): void {
        Quickshell.execDetached(["kdeconnect-sms"]);
    }

    function browseFiles(): void {
        Quickshell.execDetached(["gdbus", "call", "--session", "--dest", "org.kde.kdeconnect", "--object-path", `/modules/kdeconnect/devices/${deviceId}/sftp`, "--method", "org.kde.kdeconnect.device.sftp.startBrowsing"]);
    }

    function openDoorbell(): void {
        Quickshell.execDetached(["/home/cody/.local/bin/doorbell-view"]);
    }

    Process {
        id: pollProc

        running: true
        command: ["sh", "-c", "id=$(kdeconnect-cli -a --id-only 2>/dev/null | head -n1); echo \"$id\"; [ -n \"$id\" ] && gdbus call --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices/$id/battery --method org.freedesktop.DBus.Properties.GetAll org.kde.kdeconnect.device.battery"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text;
                root.deviceId = (out.split("\n")[0] ?? "").trim();
                const m = out.match(/'charge': <(-?\d+)>/);
                root.charge = m ? parseInt(m[1], 10) : -1;
                root.charging = out.includes("'isCharging': <true>");
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 60000
        onTriggered: pollProc.running = true
    }
}
