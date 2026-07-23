pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    readonly property string today: Qt.formatDate(new Date(), "yyyy-MM-dd")

    spacing: Tokens.spacing.small

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: "flag"
            color: Colours.palette.m3primary
            fontStyle: Tokens.font.icon.large
        }

        StyledText {
            Layout.fillWidth: true
            text: qsTr("Flagged & tasks")
            font: Tokens.font.title.small
        }

        StyledText {
            text: Tasks.visibleTasks.length > 0 ? qsTr("%1 open").arg(Tasks.visibleTasks.length) : qsTr("Clear")
            color: Tasks.visibleTasks.length > 0 ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
        }
    }

    Repeater {
        model: Tasks.visibleTasks

        StyledRect {
            id: task

            required property var modelData
            readonly property bool overdue: task.modelData.due && task.modelData.due < root.today

            Layout.fillWidth: true
            implicitHeight: taskRow.implicitHeight + Tokens.spacing.small

            radius: Tokens.rounding.small
            color: "transparent"

            RowLayout {
                id: taskRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Tokens.spacing.small

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: openRow.implicitHeight

                    radius: Tokens.rounding.small
                    color: "transparent"

                    StateLayer {
                        disabled: !task.modelData.url
                        onClicked: Qt.openUrlExternally(task.modelData.url)
                    }

                    RowLayout {
                        id: openRow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: task.modelData.flagged ? "flag" : "check_box_outline_blank"
                            color: Colours.palette.m3onSurfaceVariant
                            fontStyle: Tokens.font.icon.small
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: task.modelData.title
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }

                        StyledText {
                            visible: !!task.modelData.due
                            text: task.modelData.due
                            color: task.overdue ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.label.small
                        }
                    }
                }

                ClearButton {
                    icon: "check"
                    onClicked: {
                        Tasks.dismiss(task.modelData.id);
                        Quickshell.execDetached(["/home/cody/.local/node/bin/node", "/home/cody/Projects/Personal/teams-triage/tasks-deck.mjs", "--done", task.modelData.list, task.modelData.id]);
                    }
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: Tasks.visibleTasks.length === 0
        text: qsTr("Nothing flagged")
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
    }
}
