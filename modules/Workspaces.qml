import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    spacing: 6

    Repeater {
        model: 5

        Rectangle {
            width: 28
            height: 28
            radius: 6

            color: Hyprland.focusedWorkspace?.id === index + 1
                ? "#89b4fa"
                : "#313244"

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: "white"
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    Hyprland.dispatch(
                         "hl.dispatch(hl.dsp.focus({ workspace = " + (index + 1) + " }))"
                    )
                }
            }
        }
    }
}
