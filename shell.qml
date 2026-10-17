import Quickshell
import QtQuick
import Quickshell.Wayland
import "modules"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 10
                left: 12
                right: 12
            }

            implicitHeight: 40
            exclusiveZone: 40
            color: "transparent"

            Bar {
                anchors.fill: parent
            }
        }
    }
    Dashboard {
        id: dashboard
    }
}
