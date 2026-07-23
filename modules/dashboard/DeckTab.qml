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

        Card {
            BriefCard {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Tokens.padding.large
            }
        }

        Card {
            TriageCard {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Tokens.padding.large
            }
        }
    }

    component Card: StyledRect {
        default property Item content

        Layout.fillWidth: true
        Layout.preferredHeight: (content?.implicitHeight ?? 0) + Tokens.padding.large * 2

        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.extraLarge

        children: content ? [content] : []
    }
}
