import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

// Window-layout profile button (repurposed workspaces slot). Left-click restores the saved
// layout (relaunch missing apps + place each at its exact float geometry), right-click saves
// the current arrangement, middle-click clears it. See ~/.local/bin/layout-profile.sh.
// Personal config, NOT part of the #1182 upstream slice.
Item {
    id: root

    readonly property string script: "/home/cody/.local/bin/layout-profile.sh"

    implicitWidth: implicitHeight
    implicitHeight: icon.implicitHeight + Tokens.padding.small

    StateLayer {
        radius: Tokens.rounding.full

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                Quickshell.execDetached([root.script, "save"]);
            else if (event.button === Qt.MiddleButton)
                Quickshell.execDetached([root.script, "clear"]);
            else
                Quickshell.execDetached([root.script, "restore"]);
        }
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "space_dashboard"
        color: Colours.palette.m3onSurfaceVariant
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
