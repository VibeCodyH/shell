pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

StyledRect {
    id: root

    required property var modelData
    required property int index

    readonly property var ipcObject: modelData?.lastIpcObject ?? null
    readonly property string appClass: ipcObject?.class ?? ""
    readonly property bool dragging: (ipcObject?.address ?? "") !== "" && ipcObject?.address === TaskbarOrder.draggingAddress
    readonly property string appIcon: {
        // Prefer the desktop entry's icon (the authoritative app→icon mapping). Trusting the WM
        // class against the theme first mis-icons apps whose class collides with a theme *action*
        // icon of the same name — e.g. class "zoom" resolves to Breeze's magnifier, not the Zoom
        // logo. Fall back to the class (then the category MaterialIcon) when no entry matches.
        const entryIcon = DesktopEntries.heuristicLookup(appClass)?.icon ?? "";
        const byEntry = entryIcon ? Quickshell.iconPath(entryIcon, true) : "";
        if (byEntry)
            return byEntry;
        return appClass ? Quickshell.iconPath(appClass, true) : "";
    }
    readonly property bool active: modelData === Hypr.activeToplevel
    readonly property bool onSpecial: (ipcObject?.workspace?.name ?? "").startsWith("special:")

    function focusWindow(): void {
        const address = ipcObject?.address;
        if (!address)
            return;

        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:${address}" })` : `focuswindow address:${address}`);
    }

    // Scratchpad windows (Discord et al. parked on a special workspace) have no minimize —
    // Hyprland has no such state — so the taskbar icon toggles the special workspace instead:
    // click to peek it on top, click again to hide it and reveal the workspace behind.
    function activate(): void {
        const ws = ipcObject?.workspace?.name ?? "";
        if (ws.startsWith("special:")) {
            const name = ws.slice(8);
            Hypr.dispatch(Hypr.usingLua ? `hl.dsp.workspace.toggle_special("${name}")` : `togglespecialworkspace ${name}`);
            return;
        }
        focusWindow();
    }

    // Right-click = polite close (the app can prompt to save). Middle-click = force kill
    // (SIGKILL) for a hung app that ignores the close request. Both target THIS window by
    // address, so they never touch whatever's currently focused.
    function closeWindow(): void {
        const address = ipcObject?.address;
        if (!address)
            return;

        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.window.close({ window = "address:${address}" })` : `closewindow address:${address}`);
    }

    function forceKill(): void {
        const address = ipcObject?.address;
        if (!address)
            return;

        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.window.kill({ window = "address:${address}" })` : `killwindow address:${address}`);
    }

    implicitWidth: Tokens.sizes.bar.innerWidth - Tokens.padding.small
    implicitHeight: Tokens.sizes.bar.innerWidth - Tokens.padding.small
    color: active ? Colours.palette.m3primaryContainer : "transparent"
    radius: Tokens.rounding.full

    // Lifted look while being dragged to a new slot. Bound to taskbar.draggingAddress rather
    // than local drag state so it stays correct even if the model recreates this delegate.
    z: dragging ? 100 : 0
    scale: dragging ? 1.1 : 1
    opacity: dragging ? 0.85 : 1

    Behavior on scale {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    Behavior on opacity {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    StateLayer {
        radius: root.radius

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.closeWindow();
            else if (event.button === Qt.MiddleButton)
                root.forceKill();
            else
                root.activate();
        }
    }

    IconImage {
        anchors.fill: parent
        anchors.margins: Tokens.padding.extraSmall

        asynchronous: true
        visible: root.appIcon !== ""
        source: root.appIcon
    }

    MaterialIcon {
        anchors.centerIn: parent

        visible: root.appIcon === ""
        text: Icons.getAppCategoryIcon(root.appClass, "desktop_windows")
        color: root.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
        fontStyle: Tokens.font.icon.medium
    }

    // Scratchpad marker: an accent dot so windows parked on a special workspace (Discord,
    // the Freshdesk work window) stand apart from normal taskbar entries — they toggle
    // show/hide on click rather than just focusing.
    Rectangle {
        z: 10
        visible: root.onSpecial

        implicitWidth: Math.round(root.width * 0.3)
        implicitHeight: implicitWidth
        radius: width / 2
        color: Colours.palette.m3primary

        border.width: 1
        border.color: Colours.palette.m3surface

        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
