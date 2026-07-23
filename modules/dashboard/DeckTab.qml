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

                anchors.fill: parent
                anchors.margins: Tokens.padding.large
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: triage.implicitHeight + Tokens.padding.large * 2

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.extraLarge

            TriageCard {
                id: triage

                anchors.fill: parent
                anchors.margins: Tokens.padding.large
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: prs.implicitHeight + Tokens.padding.large * 2

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.extraLarge

            PrsCard {
                id: prs

                anchors.fill: parent
                anchors.margins: Tokens.padding.large
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: usage.implicitHeight + Tokens.padding.large * 2

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.extraLarge

            UsageCard {
                id: usage

                anchors.fill: parent
                anchors.margins: Tokens.padding.large
            }
        }
    }
}
