pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    property string icon: "close"

    signal clicked

    implicitWidth: implicitHeight
    implicitHeight: glyph.implicitHeight + Tokens.spacing.small

    radius: Tokens.rounding.full
    color: "transparent"

    StateLayer {
        onClicked: root.clicked()
    }

    MaterialIcon {
        id: glyph

        anchors.centerIn: parent
        text: root.icon
        color: Colours.palette.m3onSurfaceVariant
        fontStyle: Tokens.font.icon.small
    }
}
