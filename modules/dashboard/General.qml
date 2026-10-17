import QtQuick
import Quickshell
import Quickshell.Io

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


    // =========================================================
    // FIXED CONTENT WIDTH
    // =========================================================

    property int layoutWidth: 475


    // =========================================================
    // VOLUME
    // =========================================================

    Process {
        id: volumeProcess

        command: [
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SINK@"
        ]

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(
                    /Volume:\s+([0-9.]+)/
                )

                if (match)
                    root.volume =
                        Math.round(
                            parseFloat(match[1]) * 100
                        )
            }
        }
    }

    function refreshVolume() {
        volumeProcess.running = true
    }

    function setVolume(value) {
        value = Math.max(
            0,
            Math.min(1, value)
        )

        root.volume =
            Math.round(value * 100)

        const p = Qt.createQmlObject(
            'import Quickshell.Io; Process {' +
            'command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "' +
            value +
            '"] }',
            root
        )

        p.running = true
    }


    // =========================================================
    // BRIGHTNESS
    // =========================================================

    Process {
        id: brightnessProcess

        command: [
            "ddcutil",
            "getvcp",
            "10"
        ]

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(
                    /current value =\s*(\d+)/
                )

                if (match)
                    root.brightness =
                        parseInt(match[1])
            }
        }
    }

    function refreshBrightness() {
        brightnessProcess.running = true
    }

    function setBrightness(value) {
        value = Math.max(
            0,
            Math.min(
                100,
                Math.round(value)
            )
        )

        root.brightness = value

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
                root.brightness +
                '"] }',
                root
            )

            p.running = true
        }
    }


    // =========================================================
    // NETWORK
    // =========================================================

    Process {
        id: networkProcess

        command: [
            "nmcli",
            "-t",
            "-f",
            "TYPE,STATE,CONNECTION",
            "device"
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts =
                    data.trim().split(":")

                if (parts.length < 3)
                    return

                const type = parts[0]
                const state = parts[1]

                const connection =
                    parts.slice(2).join(":")

                if (state === "connected") {

                    if (type === "ethernet") {
                        root.networkType = "Ethernet"
                        root.networkName = connection
                    }

                    else if (type === "wifi") {
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


    // =========================================================
    // MEDIA
    // =========================================================

    Process {
        id: mediaProcess

        command: [
            "playerctl",
            "-p",
            root.player,
            "metadata",
            "--format",
            "{{artist}}|{{title}}"
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts =
                    data.trim().split("|")

                if (parts.length >= 2) {
                    root.mediaArtist = parts[0]
                    root.mediaTitle =
                        parts.slice(1).join("|")
                }
            }
        }
    }

    Process {
        id: mediaStatusProcess

        command: [
            "playerctl",
            "-p",
            root.player,
            "status"
        ]

        stdout: SplitParser {
            onRead: data => {
                root.mediaStatus =
                    data.trim()
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
            root.player +
            '", "' +
            command +
            '"] }',
            root
        )

        p.running = true
    }


    // =========================================================
    // REFRESH
    // =========================================================

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


    // =========================================================
    // LAYOUT
    // =========================================================

    Item {
        id: layout

        width: root.layoutWidth
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter


        // =====================================================
        // TITLE
        // =====================================================

        Text {
            x: 0
            y: 0

            text: "General"

            color: "#cdd6f4"

            font.pixelSize: 26
            font.weight: Font.Bold
        }

        Text {
            x: 0
            y: 38

            text: "Quick controls"

            color: "#6c7086"

            font.pixelSize: 13
        }


        // =====================================================
        // VOLUME
        // =====================================================

        Rectangle {
            x: 0
            y: 75

            width: 230
            height: 105

            radius: 10

            color: "#313244"

            border.width: 1
            border.color: "#45475a"

            Text {
                x: 15
                y: 12

                text: "󰕾  Volume"

                color: "#cdd6f4"

                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 39

                text: root.volume + "%"

                color: "#89b4fa"

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

                color: "#45475a"

                Rectangle {
                    width:
                        volumeTrack.width *
                        root.volume / 100

                    height: parent.height

                    radius: 3

                    color: "#89b4fa"
                }

                MouseArea {
                    anchors.fill: parent

                    property bool dragging: false

                    function updateVolume(mouseX) {
                        const value =
                            Math.max(
                                0,
                                Math.min(
                                    1,
                                    mouseX /
                                    volumeTrack.width
                                )
                            )

                        root.setVolume(value)
                    }

                    onPressed: {
                        dragging = true
                        updateVolume(mouse.x)
                    }

                    onReleased: {
                        dragging = false
                    }

                    onPositionChanged: {
                        if (dragging)
                            updateVolume(mouse.x)
                    }
                }
            }
        }


        // =====================================================
        // BRIGHTNESS
        // =====================================================

        Rectangle {
            x: 245
            y: 75

            width: 230
            height: 105

            radius: 10

            color: "#313244"

            border.width: 1
            border.color: "#45475a"

            Text {
                x: 15
                y: 12

                text: "󰃠  Brightness"

                color: "#cdd6f4"

                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 39

                text: root.brightness + "%"

                color: "#f9e2af"

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

                color: "#45475a"

                Rectangle {
                    width:
                        brightnessTrack.width *
                        root.brightness / 100

                    height: parent.height

                    radius: 3

                    color: "#f9e2af"
                }

                MouseArea {
                    anchors.fill: parent

                    property bool dragging: false

                    function updateBrightness(mouseX) {
                        const value =
                            Math.max(
                                0,
                                Math.min(
                                    100,
                                    Math.round(
                                        mouseX /
                                        brightnessTrack.width *
                                        100
                                    )
                                )
                            )

                        root.setBrightness(value)
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


        // =====================================================
        // NETWORK
        // =====================================================

        Rectangle {
            x: 0
            y: 195

            width: 475
            height: 75

            radius: 10

            color: "#313244"

            border.width: 1
            border.color: "#45475a"

            Text {
                x: 15
                y: 14

                text:
                    root.networkType === "Ethernet"
                    ? "󰈀  Network"
                    : "󰤨  Network"

                color: "#cdd6f4"

                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 42

                text: root.networkName

                color:
                    root.networkName === "Checking..."
                    ? "#6c7086"
                    : "#a6e3a1"

                font.pixelSize: 14
            }
        }


        // =====================================================
        // MEDIA
        // =====================================================

        Rectangle {
            x: 0
            y: 285

            width: 475
            height: 95

            radius: 10

            color: "#313244"

            border.width: 1
            border.color: "#45475a"

            Text {
                x: 15
                y: 12

                text: "󰝚  Media"

                color: "#cdd6f4"

                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Text {
                x: 15
                y: 40

                width: 300

                text:
                    root.mediaTitle === "No media"
                    ? "No media"
                    : root.mediaTitle

                color: "#f5f5f5"

                font.pixelSize: 14

                elide: Text.ElideRight
            }

            Text {
                x: 15
                y: 62

                width: 300

                text: root.mediaArtist

                color: "#6c7086"

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

                color: "#45475a"

                Text {
                    anchors.centerIn: parent

                    text: "󰒮"

                    color: "#cdd6f4"

                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.mediaCommand("previous")
                }
            }


            // PLAY / PAUSE
            Rectangle {
                x: 370
                y: 42

                width: 40
                height: 35

                radius: 8

                color: "#89b4fa"

                Text {
                    anchors.centerIn: parent

                    text:
                        root.mediaStatus === "Playing"
                        ? "󰏤"
                        : "󰐊"

                    color: "#1e1e2e"

                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.mediaCommand("play-pause")
                }
            }


            // NEXT
            Rectangle {
                x: 415
                y: 42

                width: 40
                height: 35

                radius: 8

                color: "#45475a"

                Text {
                    anchors.centerIn: parent

                    text: "󰒭"

                    color: "#cdd6f4"

                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.mediaCommand("next")
                }
            }
        }
    }
}
