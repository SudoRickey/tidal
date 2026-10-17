import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    implicitWidth: 70
    implicitHeight: 30

    property int volume: 0
    property bool muted: false

    function refresh() {
        proc.running = true
    }

    function setVolume(value) {
        root.volume = Math.round(value * 100)

        const p = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "' + value + '"] }',
            root
        )
        p.running = true
    }

    Process {
        id: proc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(
                    /Volume:\s+([0-9.]+)(\s+\[MUTED\])?/
                )

                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100)
                    root.muted = !!match[2]
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Text {
        anchors.centerIn: parent

        color: root.muted ? "#ff5555" : "#f5f5f5"
        font.pixelSize: 16
        font.weight: Font.Medium

        text: root.muted
            ? "󰝟  Muted"
            : "󰕾  " + root.volume + "%"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: popup.visible = !popup.visible
    }

    PanelWindow {
        id: popup

        visible: false

        anchors.top: true
        anchors.right: true

        margins.top: 5
        margins.right: 12

        implicitWidth: 240
        implicitHeight: 60

        color: "transparent"

        Rectangle {
            anchors.fill: parent

            radius: 14
            color: "#1e1e2e66"

            border.width: 1
            border.color: "#89b4facc"

            Text {
                x: 15
                anchors.verticalCenter: parent.verticalCenter

                text: root.muted ? "󰝟" : "󰕾"
                color: root.muted ? "#ff5555" : "#f5f5f5"
                font.pixelSize: 20
            }

            Rectangle {
                id: track

                x: 48
                anchors.verticalCenter: parent.verticalCenter

                width: 175
                height: 6

                radius: 3
                color: "#313244"

                Rectangle {
                    width: track.width * root.volume / 100
                    height: track.height
                    radius: 3
                    color: "#89b4fa"
                }

                MouseArea {
                    anchors.fill: parent

                    function updateVolume(x) {
                        const value = Math.max(
                            0,
                            Math.min(1, x / track.width)
                        )

                        root.setVolume(value)
                    }

                    onPressed: updateVolume(mouse.x)

                    onPositionChanged: {
                        if (pressed)
                            updateVolume(mouse.x)
                    }
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5

                text: root.volume + "%"
                color: "#f5f5f5"
                font.pixelSize: 11
            }
        }
    }
}
