pragma ComponentBehavior: Bound

import "deck"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    implicitWidth: Tokens.sizes.dashboard.userWidth * 2
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Tokens.spacing.medium

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: brief.implicitHeight + Tokens.padding.large * 2

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.extraLarge

            BriefCard {
                id: brief

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Tokens.padding.large
            }
        }
    }
}
