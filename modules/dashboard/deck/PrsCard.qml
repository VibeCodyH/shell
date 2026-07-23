pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    spacing: Tokens.spacing.small

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: "merge"
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.large
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("WOWnet PRs")
            font: Tokens.font.title.small
        }

        StyledText {
            text: PullRequests.prs.length > 0 ? qsTr("%1 open").arg(PullRequests.prs.length) : qsTr("None")
            color: PullRequests.prs.length > 0 ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
            horizontalAlignment: Text.AlignRight
        }
    }

    Repeater {
        model: PullRequests.prs

        StyledRect {
            id: pr

            required property var modelData

            Layout.fillWidth: true
            implicitHeight: prRow.implicitHeight + Tokens.spacing.small

            radius: Tokens.rounding.small
            color: "transparent"

            StateLayer {
                disabled: !pr.modelData.url
                onClicked: Qt.openUrlExternally(pr.modelData.url)
            }

            RowLayout {
                id: prRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Tokens.spacing.small

                StyledText {
                    text: `#${pr.modelData.number}`
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }

                StyledText {
                    Layout.fillWidth: true
                    text: pr.modelData.title
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: pr.modelData.isDraft ? qsTr("draft") : pr.modelData.reviewDecision === "APPROVED" ? qsTr("approved") : pr.modelData.reviewDecision === "CHANGES_REQUESTED" ? qsTr("changes") : qsTr("review")
                    color: pr.modelData.isDraft ? Colours.palette.m3onSurfaceVariant : pr.modelData.reviewDecision === "APPROVED" ? Colours.palette.m3primary : pr.modelData.reviewDecision === "CHANGES_REQUESTED" ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: PullRequests.prs.length === 0
        text: qsTr("No open PRs")
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
    }
}
