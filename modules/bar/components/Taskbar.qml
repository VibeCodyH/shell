pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    required property bool horizontal

    clip: true
    implicitWidth: horizontal ? layout.implicitWidth : Tokens.sizes.bar.innerWidth
    implicitHeight: horizontal ? Tokens.sizes.bar.innerWidth : layout.implicitHeight

    Grid {
        id: layout

        anchors.centerIn: parent
        columns: root.horizontal ? Math.max(1, items.count) : 1
        spacing: Tokens.spacing.extraSmall

        Repeater {
            id: items

            model: ScriptModel {
                values: Hypr.toplevels.values
            }

            TaskbarItem {}
        }
    }
}
