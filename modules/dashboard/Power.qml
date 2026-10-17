
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../config" as Config

Item {
    id: root

    function runAction(action) {
        if (action === "lock") {
            actionProcess.command = ["hyprlock"]
        } else if (action === "sleep") {
            actionProcess.command = ["systemctl", "suspend"]
        } else if (action === "logout") {
            actionProcess.command = ["hyprctl", "dispatch", "exit"]
        } else if (action === "reboot") {
            actionProcess.command = ["systemctl", "reboot"]
        } else if (action === "shutdown") {
            actionProcess.command = ["systemctl", "poweroff"]
        }

        actionProcess.running = true
    }

    Process {
        id: actionProcess
        command: ["true"]
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Power"
            color: Config.Theme.text
            font.pixelSize: 22
            font.bold: true
        }

        Text {
            text: "Manage your session and system"
            color: Config.Theme.muted
            font.pixelSize: 12
            Layout.bottomMargin: 8
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: [
                    {
                        title: "Lock",
                        description: "Lock your screen",
                        symbol: "󰌾",
                        action: "lock"
                    },
                    {
                        title: "Sleep",
                        description: "Suspend your PC",
                        symbol: "󰤄",
                        action: "sleep"
                    },
                    {
                        title: "Logout",
                        description: "End your session",
                        symbol: "󰍃",
                        action: "logout"
                    },
                    {
                        title: "Reboot",
                        description: "Restart your PC",
                        symbol: "󰜉",
                        action: "reboot"
                    },
                    {
                        title: "Shutdown",
                        description: "Power off your PC",
                        symbol: "󰐥",
                        action: "shutdown"
                    }
                ]

                delegate: Rectangle {
                    id: actionCard

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 86

                    radius: 10
                    color: mouseArea.containsMouse
                           ? Qt.darker(Config.Theme.accent, 1.15)
                           : Config.Theme.surface

                    border.width: 1
                    border.color: mouseArea.containsMouse
                                  ? Config.Theme.accent
                                  : Config.Theme.border

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: actionCard.modelData.symbol
                            color: Config.Theme.accent
                            font.pixelSize: 25
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: actionCard.modelData.title
                                color: Config.Theme.text
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: actionCard.modelData.description
                                color: Config.Theme.muted
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.runAction(actionCard.modelData.action)
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            text: "System actions execute immediately."
            color: Config.Theme.muted
            font.pixelSize: 10
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
