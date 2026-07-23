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
            text: "forum"
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.large
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Teams triage")
            font: Tokens.font.title.small
        }

        StyledText {
            text: TeamsTriage.items.length > 0 ? qsTr("%1 to action").arg(TeamsTriage.items.length) : qsTr("Clear")
            color: TeamsTriage.items.length > 0 ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }

    Repeater {
        model: TeamsTriage.items

        ColumnLayout {
            id: item

            required property var modelData

            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: `${item.modelData.from} · ${item.modelData.source}`
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: item.modelData.text
                font: Tokens.font.body.small
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: TeamsTriage.items.length === 0
        text: qsTr("Nothing awaiting your reply")
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
    }
}
