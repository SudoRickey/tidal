
import QtQuick
import Quickshell
import Quickshell.Io
import "../../config" as Config

Item {
    id: root

    property int volume: 0
    property int brightness: 50

    property string networkType: "Network"
    property string networkName: "Checking..."

    property string player: "chromium.instance18344"
    property string mediaTitle: "No media"
    property string mediaArtist: ""
    property string mediaStatus: "Stopped"

    property int layoutWidth: 475

    readonly property color cardColor: Config.Theme.surface
    readonly property color textColor: Config.Theme.text
    readonly property color accentColor: Config.Theme.accent
    readonly property color borderColor: Config.Theme.border
    readonly property color mutedColor: Config.Theme.muted

    // VOLUME

    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Volume:\s+([0-9.]+)/)
                if (match)
                    root.volume = Math.round(parseFloat(match[1]) * 100)
            }
        }
    }

    function refreshVolume() {
        volumeProcess.running = true
    }

    function setVolume(value) {
        value = Math.max(0, Math.min(1, value))
        root.volume = Math.round(value * 100)

        const p = Qt.createQmlObject(
            'import Quickshell.Io; Process {' +
            'command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "' +
            value + '"] }',
            root
        )
        p.running = true
    }

    // BRIGHTNESS

    Process {
        id: brightnessProcess
        command: ["ddcutil", "getvcp", "10"]

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/current value =\s*(\d+)/)
                if (match)
                    root.brightness = parseInt(match[1])
            }
        }
    }

    function refreshBrightness() {
        brightnessProcess.running = true
    }

    function setBrightness(value) {
        root.brightness = Math.max(0, Math.min(100, Math.round(value)))
        brightnessSendTimer.restart()
    }

    Timer {
        id: brightnessSendTimer
        interval: 200
        repeat: false

        onTriggered: {
            const p = Qt.createQmlObject(
                'import Quickshell.Io; Process {' +
                'command: ["ddcutil", "setvcp", "10", "' +
                root.brightness + '"] }',
                root
            )
            p.running = true
        }
    }

    // NETWORK

    Process {
        id: networkProcess
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(":")
                if (parts.length < 3)
                    return

                const type = parts[0]
                const state = parts[1]
                const connection = parts.slice(2).join(":")

                if (state === "connected") {
                    if (type === "ethernet") {
                        root.networkType = "Ethernet"
                        root.networkName = connection
                    } else if (type === "wifi") {
                        root.networkType = "Wi-Fi"
                        root.networkName = connection
                    }
                }
            }
        }
    }

    function refreshNetwork() {
        networkProcess.running = true
    }

    // MEDIA

    Process {
        id: mediaProcess
        command: [
            "playerctl", "-p", root.player,
            "metadata", "--format", "{{artist}}|{{title}}"
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length >= 2) {
                    root.mediaArtist = parts[0]
                    root.mediaTitle = parts.slice(1).join("|")
                }
            }
        }
    }

    Process {
        id: mediaStatusProcess
        command: ["playerctl", "-p", root.player, "status"]

        stdout: SplitParser {
            onRead: data => {
                root.mediaStatus = data.trim()
            }
        }
    }

    function refreshMedia() {
        mediaProcess.running = true
        mediaStatusProcess.running = true
    }

    function mediaCommand(command) {
        const p = Qt.createQmlObject(
            'import Quickshell.Io; Process {' +
            'command: ["playerctl", "-p", "' +
            root.player + '", "' + command + '"] }',
            root
        )
        p.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            root.refreshVolume()
            root.refreshBrightness()
            root.refreshNetwork()
            root.refreshMedia()
        }
    }

    // LAYOUT

    Item {
        id: layout
        width: root.layoutWidth
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            x: 0
            y: 0
            text: "General"
            color: root.textColor
            font.pixelSize: 26
            font.weight: Font.Bold
        }

        Text {
            x: 0
            y: 38
            text: "Quick controls"
            color: root.mutedColor
            font.pixelSize: 13
        }

        // VOLUME CARD

        Rectangle {
            x: 0
            y: 75
            width: 230
            height: 105
            radius: 10
            color: root.cardColor
            border.width: 1
            border.color: root.borderColor

            Text {
                x: 15
                y: 12
                text: "󰕾  Volume"
                color: root.textColor
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 39
                text: root.volume + "%"
                color: root.accentColor
                font.pixelSize: 22
                font.weight: Font.Bold
            }

            Rectangle {
                id: volumeTrack
                x: 15
                y: 76
                width: 200
                height: 6
                radius: 3
                color: root.borderColor

                Rectangle {
                    width: volumeTrack.width * root.volume / 100
                    height: parent.height
                    radius: 3
                    color: root.accentColor
                }

                MouseArea {
                    anchors.fill: parent
                    property bool dragging: false

                    function updateVolume(mouseX) {
                        root.setVolume(Math.max(
                            0, Math.min(1, mouseX / volumeTrack.width)
                        ))
                    }

                    onPressed: {
                        dragging = true
                        updateVolume(mouse.x)
                    }

                    onReleased: dragging = false

                    onPositionChanged: {
                        if (dragging)
                            updateVolume(mouse.x)
                    }
                }
            }
        }

        // BRIGHTNESS CARD

        Rectangle {
            x: 245
            y: 75
            width: 230
            height: 105
            radius: 10
            color: root.cardColor
            border.width: 1
            border.color: root.borderColor

            Text {
                x: 15
                y: 12
                text: "󰃠  Brightness"
                color: root.textColor
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 39
                text: root.brightness + "%"
                color: root.accentColor
                font.pixelSize: 22
                font.weight: Font.Bold
            }

            Rectangle {
                id: brightnessTrack
                x: 15
                y: 76
                width: 200
                height: 6
                radius: 3
                color: root.borderColor

                Rectangle {
                    width: brightnessTrack.width * root.brightness / 100
                    height: parent.height
                    radius: 3
                    color: root.accentColor
                }

                MouseArea {
                    anchors.fill: parent
                    property bool dragging: false

                    function updateBrightness(mouseX) {
                        root.setBrightness(Math.max(
                            0,
                            Math.min(
                                100,
                                Math.round(mouseX / brightnessTrack.width * 100)
                            )
                        ))
                    }

                    onPressed: {
                        dragging = true
                        updateBrightness(mouse.x)
                    }

                    onReleased: {
                        dragging = false
                        brightnessSendTimer.restart()
                    }

                    onPositionChanged: {
                        if (dragging)
                            updateBrightness(mouse.x)
                    }
                }
            }
        }

        // NETWORK CARD

        Rectangle {
            x: 0
            y: 195
            width: 475
            height: 75
            radius: 10
            color: root.cardColor
            border.width: 1
            border.color: root.borderColor

            Text {
                x: 15
                y: 14
                text: root.networkType === "Ethernet"
                      ? "󰈀  Network" : "󰤨  Network"
                color: root.textColor
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 42
                text: root.networkName
                color: root.mutedColor
                font.pixelSize: 14
            }
        }

        // MEDIA CARD

        Rectangle {
            x: 0
            y: 285
            width: 475
            height: 95
            radius: 10
            color: root.cardColor
            border.width: 1
            border.color: root.borderColor

            Text {
                x: 15
                y: 12
                text: "󰝚  Media"
                color: root.textColor
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 40
                width: 300
                text: root.mediaTitle
                color: root.textColor
                font.pixelSize: 14
                elide: Text.ElideRight
            }

            Text {
                x: 15
                y: 62
                width: 300
                text: root.mediaArtist
                color: root.mutedColor
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            // PREVIOUS

            Rectangle {
                x: 325
                y: 42
                width: 40
                height: 35
                radius: 8
                color: previousMouse.containsMouse
                       ? root.accentColor : root.borderColor

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: root.textColor
                    font.pixelSize: 18
                }

                MouseArea {
                    id: previousMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.mediaCommand("previous")
                }
            }

            // PLAY / PAUSE

            Rectangle {
                x: 370
                y: 42
                width: 40
                height: 35
                radius: 8
                color: root.accentColor

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.mediaStatus === "Playing"
                          ? "󰏤" : "󰐊"
                    color: Config.Theme.background
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.mediaCommand("play-pause")
                }
            }

            // NEXT

            Rectangle {
                x: 415
                y: 42
                width: 40
                height: 35
                radius: 8
                color: nextMouse.containsMouse
                       ? root.accentColor : root.borderColor

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: root.textColor
                    font.pixelSize: 18
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.mediaCommand("next")
                }
            }
        }
    }
}
