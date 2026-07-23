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
    readonly property string appIcon: {
        // WM class usually matches the theme icon name directly; fall back to the desktop entry
        const byClass = appClass ? Quickshell.iconPath(appClass, true) : "";
        if (byClass)
            return byClass;
        const entryIcon = DesktopEntries.heuristicLookup(appClass)?.icon ?? "";
        return entryIcon ? Quickshell.iconPath(entryIcon, true) : "";
    }
    readonly property bool active: modelData === Hypr.activeToplevel

    function focusWindow(): void {
        const address = ipcObject?.address;
        if (!address)
            return;

        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ window = "address:${address}" })` : `focuswindow address:${address}`);
    }

    implicitWidth: Tokens.sizes.bar.innerWidth - Tokens.padding.small
    implicitHeight: Tokens.sizes.bar.innerWidth - Tokens.padding.small
    color: active ? Colours.palette.m3primaryContainer : "transparent"
    radius: Tokens.rounding.full

    StateLayer {
        radius: root.radius
        onClicked: root.focusWindow()
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
}
