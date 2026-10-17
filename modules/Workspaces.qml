
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../config" as Config

Row {
    spacing: 6

    Repeater {
        model: 5

        delegate: Rectangle {
            id: workspaceButton

            required property int index

            width: 28
            height: 28
            radius: 6

            readonly property bool isFocused:
                Hyprland.focusedWorkspace?.id === index + 1

            color: isFocused
                ? Config.Theme.accent
                : mouseArea.containsMouse
                    ? "#3b4252"
                    : "#242833"

            border.width: 1
            border.color: isFocused
                ? Config.Theme.accent
                : "#454b5b"

            Behavior on color {
                ColorAnimation { duration: 140 }
            }

            Text {
                anchors.centerIn: parent
                text: workspaceButton.index + 1

                color: workspaceButton.isFocused
                    ? "#171923"
                    : "#e5e9f0"

                font.pixelSize: 14
                font.weight: workspaceButton.isFocused
                    ? Font.Bold
                    : Font.Medium
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    Hyprland.dispatch(
                        "hl.dispatch(hl.dsp.focus({ workspace = " +
                        (workspaceButton.index + 1) + " }))"
                )
                }
            }
        }
    }
}
