pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

// Phone quick-tools popout (fork-only): doorbell live view + KDE Connect actions.
Column {
    id: root

    spacing: Tokens.spacing.small
    width: Tokens.sizes.bar.batteryWidth

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter

        text: {
            if (!Phone.online)
                return qsTr("Phone offline");
            if (Phone.charge < 0)
                return qsTr("Phone connected");
            return qsTr("Phone · %1%%2").arg(Phone.charge).arg(Phone.charging ? " ⚡" : "");
        }
        font: Tokens.font.mono.builders.medium.weight(Font.Medium).build()
    }

    ActionButton {
        icon: "doorbell"
        label: qsTr("Doorbell cam")
        requiresPhone: false

        onClicked: Phone.openDoorbell()
    }

    ActionButton {
        icon: "content_paste_go"
        label: qsTr("Send clipboard")

        onClicked: Phone.sendClipboard()
    }

    ActionButton {
        icon: "upload_file"
        label: qsTr("Send file")

        onClicked: Phone.shareFile()
    }

    ActionButton {
        icon: "sms"
        label: qsTr("Messages")

        onClicked: Phone.openMessages()
    }

    ActionButton {
        icon: "folder_open"
        label: qsTr("Browse phone")

        onClicked: Phone.browseFiles()
    }

    component ActionButton: StyledRect {
        id: action

        required property string icon
        required property string label
        property bool requiresPhone: true
        readonly property bool available: !requiresPhone || Phone.online

        signal clicked

        width: parent.width
        implicitHeight: actionRow.implicitHeight + Tokens.padding.small * 2

        radius: Tokens.rounding.medium
        opacity: available ? 1 : 0.4

        StateLayer {
            disabled: !action.available

            onClicked: action.clicked()
        }

        Row {
            id: actionRow

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Tokens.padding.medium

            spacing: Tokens.spacing.medium

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter

                text: action.icon
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: action.label
            }
        }
    }
}
