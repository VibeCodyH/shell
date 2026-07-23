pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property var modelData

    readonly property var ipcObject: modelData?.lastIpcObject ?? null
    readonly property string appClass: ipcObject?.class ?? ""
    readonly property DesktopEntry desktopEntry: appClass ? DesktopEntries.heuristicLookup(appClass) : null
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
        visible: root.desktopEntry !== null
        source: Quickshell.iconPath(root.desktopEntry?.icon, "image-missing")
    }

    MaterialIcon {
        anchors.centerIn: parent

        visible: root.desktopEntry === null
        text: Icons.getAppCategoryIcon(root.appClass, "desktop_windows")
        color: root.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
        fontStyle: Tokens.font.icon.medium
    }
}
