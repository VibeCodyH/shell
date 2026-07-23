pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    required property date selectedDate

    readonly property list<var> events: CalendarEvents.eventsForDate(selectedDate).slice(0, Config.dashboard.calendar.maxShown)

    spacing: Tokens.spacing.small
    visible: events.length > 0

    Repeater {
        model: root.events

        RowLayout {
            id: row

            required property var modelData

            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 3
                implicitHeight: title.implicitHeight
                radius: Tokens.rounding.full
                color: row.modelData.color || Colours.palette.m3primary
            }

            StyledText {
                id: title

                Layout.fillWidth: true
                text: row.modelData.title
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }

            StyledText {
                text: row.modelData.allDay ? qsTr("All day") : Qt.formatTime(row.modelData.start, "h:mm AP")
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.builders.small.scale(0.9).build()
            }
        }
    }
}
