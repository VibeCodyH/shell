pragma ComponentBehavior: Bound

import "deck"
import QtQuick.Layouts
import qs.components

ColumnLayout {
    id: root

    readonly property int cardWidth: Tokens.sizes.dashboard.userWidth * 2

    spacing: Tokens.spacing.medium

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredWidth: root.cardWidth
        Layout.preferredHeight: brief.implicitHeight + brief.anchors.margins * 2

        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.extraLarge

        BriefCard {
            id: brief

            anchors.fill: parent
            anchors.margins: Tokens.padding.large
        }
    }
}
