pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

ColumnLayout {
    id: root

    spacing: Tokens.spacing.small

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: "wb_twilight"
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.large
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Daily Brief")
            font: Tokens.font.title.small
        }

        StyledText {
            text: Brief.count > 0 ? qsTr("%1 open").arg(Brief.count) : qsTr("All clear")
            color: Brief.count > 0 ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }

    Repeater {
        model: Brief.rows

        RowLayout {
            id: row

            required property var modelData

            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                Layout.alignment: Qt.AlignTop
                text: `${row.modelData.n}.`
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
            }

            StyledText {
                Layout.fillWidth: true
                text: row.modelData.label
                font: Tokens.font.body.small
                wrapMode: Text.WordWrap
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: Brief.calendarCount > 0
        text: qsTr("%1 event(s) today").arg(Brief.calendarCount)
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.label.small
    }
}
