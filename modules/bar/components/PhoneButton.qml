import QtQuick
import Caelestia.Config
import qs.components
import qs.services

// Phone quick-tools entry (fork-only): hover opens the "phone" popout with
// doorbell cam + KDE Connect actions. State/actions live in services/Phone.qml.
Item {
    id: root

    implicitWidth: implicitHeight
    implicitHeight: icon.implicitHeight + Tokens.padding.small

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "smartphone"
        color: Phone.online ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outline
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
