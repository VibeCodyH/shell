pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    readonly property list<var> todayEvents: CalendarEvents.eventsForDate(new Date())

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
            text: Brief.visibleRows.length > 0 ? qsTr("%1 open").arg(Brief.visibleRows.length) : qsTr("All clear")
            color: Brief.visibleRows.length > 0 ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }

    Repeater {
        model: Brief.visibleRows

        StyledRect {
            id: row

            required property var modelData

            Layout.fillWidth: true
            implicitHeight: briefRow.implicitHeight + Tokens.spacing.small

            radius: Tokens.rounding.small
            color: "transparent"

            RowLayout {
                id: briefRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
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

                ClearButton {
                    Layout.alignment: Qt.AlignTop
                    icon: "check"
                    onClicked: Brief.dismiss(row.modelData.key)
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.small / 2
        visible: root.todayEvents.length > 0
        text: qsTr("Today")
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.label.small
    }

    Repeater {
        model: root.todayEvents

        RowLayout {
            id: evRow

            required property var modelData

            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                text: evRow.modelData.allDay ? qsTr("All day") : Qt.formatTime(evRow.modelData.start, "h:mm AP")
                color: Colours.palette.m3primary
                font: Tokens.font.body.builders.small.scale(0.9).build()
            }

            StyledText {
                Layout.fillWidth: true
                text: evRow.modelData.title
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }
        }
    }
}
