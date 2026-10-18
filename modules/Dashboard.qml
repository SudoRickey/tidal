import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls
import Quickshell.Io
import "../config" as ThemeConfig
import "./dashboard"

PanelWindow {
    id: dashboard

    WlrLayershell.namespace: "dashboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool opened: false
    property string currentPage: "general"
    property real slideProgress: opened ? 1 : 0

    visible: opened || slideProgress > 0.001

    Behavior on slideProgress {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    IpcHandler {
        target: "dashboard"

        function toggle() {
            dashboard.opened = !dashboard.opened
        }

        function open() {
            dashboard.opened = true
        }

        function close() {
            dashboard.opened = false
        }
    }

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        left: 650
        right: 650
        bottom: -(1 - dashboard.slideProgress) * dashboard.implicitHeight
    }

    implicitHeight: 460
    exclusiveZone: 0
    color: "transparent"

    // MAIN ROUNDED DASHBOARD
    Rectangle {
        id: background

        anchors.fill: parent
        radius: 16
        clip: true
        antialiasing: true

        color: Qt.rgba(
            ThemeConfig.Theme.background.r,
            ThemeConfig.Theme.background.g,
            ThemeConfig.Theme.background.b,
            0.65
        )

        border.width: 1
        border.color: Qt.rgba(
            ThemeConfig.Theme.accent.r,
            ThemeConfig.Theme.accent.g,
            ThemeConfig.Theme.accent.b,
            0.65
        )

        // CONTENT
        Item {
            id: content
            z: 1

            anchors {
                fill: parent
                leftMargin: 108
                rightMargin: 32
                topMargin: 24
                bottomMargin: 24
            }

            General {
                anchors.fill: parent
                visible: dashboard.currentPage === "general"
            }

            Wallpaper {
                anchors.fill: parent
                visible: dashboard.currentPage === "wallpaper"
            }

            Hardware {
                anchors.fill: parent
                visible: dashboard.currentPage === "hardware"
            }

            DatePage {
                anchors.fill: parent
                visible: dashboard.currentPage === "date"
            }

            Power {
                anchors.fill: parent
                visible: dashboard.currentPage === "power"
            }
        }

        // SIDEBAR HOVER DETECTOR
        MouseArea {
            id: sidebarHover
            z: 2
            hoverEnabled: true

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            width: 190
        }

        // SIDEBAR
        Rectangle {
            id: sidebar

            z: 3

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: 1
                topMargin: 1
                bottomMargin: 1
            }

            width: (sidebarHover.containsMouse ? 190 : 76) - 1

            color: ThemeConfig.Theme.surface
            radius: 15
            antialiasing: true
            clip: true

            border.width: 0

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 20
                }

                spacing: 10

                Repeater {
                    model: [
                        ["󰍜", "General", "general"],
                        ["󰸉", "Wallpaper", "wallpaper"],
                        ["󰢮", "Hardware", "hardware"],
                        ["󰃭", "Calendar", "date"],
                        ["󰐥", "Power", "power"]
                    ]

                    delegate: Item {
                        required property var modelData

                        width: parent.width
                        height: 44

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: 10
                                rightMargin: 10
                            }

                            height: 44
                            radius: 8

                            color: dashboard.currentPage === modelData[2]
                                ? Qt.rgba(
                                    ThemeConfig.Theme.accent.r,
                                    ThemeConfig.Theme.accent.g,
                                    ThemeConfig.Theme.accent.b,
                                    0.20
                                )
                                : "transparent"

                            border.width:
                                dashboard.currentPage === modelData[2] ? 1 : 0

                            border.color: ThemeConfig.Theme.accent
                        }

                        Rectangle {
                            visible:
                                dashboard.currentPage === modelData[2]

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            width: 3
                            height: 22
                            radius: 2
                            color: ThemeConfig.Theme.accent
                        }

                        Text {
                            id: icon

                            anchors {
                                left: parent.left
                                leftMargin: 25
                                verticalCenter: parent.verticalCenter
                            }

                            text: modelData[0]

                            color: dashboard.currentPage === modelData[2]
                                ? ThemeConfig.Theme.text
                                : ThemeConfig.Theme.muted

                            font.pixelSize: 21
                        }

                        Text {
                            anchors {
                                left: icon.right
                                leftMargin: 14
                                verticalCenter: parent.verticalCenter
                            }

                            text: modelData[1]
                            color: ThemeConfig.Theme.text

                            font {
                                pixelSize: 15
                                weight: Font.Medium
                            }

                            visible: sidebar.width > 100
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: 10
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                dashboard.currentPage = modelData[2]
                            }
                        }
                    }
                }
            }
        }
    }
}
