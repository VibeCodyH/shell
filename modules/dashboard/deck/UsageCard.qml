pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    function untilReset(unixSec: double): string {
        const ms = unixSec * 1000 - Date.now();
        if (ms <= 0)
            return qsTr("now");
        const mins = Math.floor(ms / 60000);
        const hours = Math.floor(mins / 60);
        const days = Math.floor(hours / 24);
        if (days > 0)
            return qsTr("%1d %2h").arg(days).arg(hours % 24);
        if (hours > 0)
            return qsTr("%1h %2m").arg(hours).arg(mins % 60);
        return qsTr("%1m").arg(mins);
    }

    spacing: Tokens.spacing.small

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: "speed"
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.large
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Usage")
            font: Tokens.font.title.small
        }
    }

    Gauge {
        label: qsTr("5h")
        pct: Usage.fiveHourPct
        reset: Usage.fiveHourReset
    }

    Gauge {
        label: qsTr("7d")
        pct: Usage.sevenDayPct
        reset: Usage.sevenDayReset
    }

    StyledText {
        Layout.fillWidth: true
        visible: !Usage.valid
        text: qsTr("No usage data yet")
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
    }

    component Gauge: RowLayout {
        id: gauge

        required property string label
        required property int pct
        required property double reset

        readonly property color accent: pct >= 85 ? Colours.palette.m3error : Colours.palette.m3primary

        Layout.fillWidth: true
        visible: Usage.valid
        spacing: Tokens.spacing.small

        StyledText {
            Layout.preferredWidth: Tokens.font.body.small.pixelSize * 2
            text: gauge.label
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: Tokens.rounding.full
            color: Colours.palette.m3surfaceContainerHighest

            StyledRect {
                width: parent.width * Math.min(1, gauge.pct / 100)
                height: parent.height
                radius: parent.radius
                color: gauge.accent
            }
        }

        StyledText {
            text: qsTr("%1% · %2").arg(gauge.pct).arg(root.untilReset(gauge.reset))
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.builders.small.scale(0.9).build()
        }
    }
}
