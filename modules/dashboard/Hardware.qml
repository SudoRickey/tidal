
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../config" as Config

Item {
    id: root

    property real cpuUsage: -1
    property real previousCpuTotal: 0
    property real previousCpuIdle: 0

    property real ramUsed: 0
    property real ramTotal: 0
    property real ramUsage: 0

    property real gpuUsage: -1
    property real gpuMemoryUsed: 0
    property real gpuMemoryTotal: 0
    property int gpuTemperature: -1
    property bool gpuAvailable: false

    function updateStats(output) {
        const lines = output.trim().split("\n")

        // CPU usage from /proc/stat
        if (lines.length > 0) {
            const cpu = lines[0].trim().split(/\s+/)

            if (cpu.length >= 8) {
                let total = 0

                for (let i = 1; i <= 8; i++)
                    total += Number(cpu[i])

                const idle = Number(cpu[4]) + Number(cpu[5])

                if (previousCpuTotal > 0 && total > previousCpuTotal) {
                    const totalDelta = total - previousCpuTotal
                    const idleDelta = idle - previousCpuIdle

                    cpuUsage = Math.max(0, Math.min(
                        100,
                        (totalDelta - idleDelta) / totalDelta * 100
                    ))
                }

                previousCpuTotal = total
                previousCpuIdle = idle
            }
        }

        // RAM values from /proc/meminfo, in kB
        let totalKb = 0
        let availableKb = 0

        for (let i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("MemTotal:"))
                totalKb = Number(lines[i].split(/\s+/)[1])

            if (lines[i].startsWith("MemAvailable:"))
                availableKb = Number(lines[i].split(/\s+/)[1])
        }

        if (totalKb > 0) {
            ramTotal = totalKb / 1048576
            ramUsed = (totalKb - availableKb) / 1048576
            ramUsage = (totalKb - availableKb) / totalKb * 100
        }

        // NVIDIA GPU: utilization, VRAM used, VRAM total, temperature
        gpuAvailable = false

        if (lines.length > 3 &&
            lines[3].trim() !== "" &&
            lines[3].trim() !== "unavailable") {

            const gpu = lines[3].split(",").map(
                value => value.trim()
            )

            if (gpu.length >= 4 &&
                !isNaN(Number(gpu[0])) &&
                !isNaN(Number(gpu[1])) &&
                !isNaN(Number(gpu[2]))) {

                gpuUsage = Number(gpu[0])
                gpuMemoryUsed = Number(gpu[1]) / 1024
                gpuMemoryTotal = Number(gpu[2]) / 1024

                gpuTemperature = isNaN(Number(gpu[3]))
                    ? -1 : Number(gpu[3])

                gpuAvailable = true
            }
        }

        if (!gpuAvailable) {
            gpuUsage = -1
            gpuTemperature = -1
        }
    }

    Process {
        id: statsProcess

        command: [
            "bash", "-c",
            "head -n 1 /proc/stat; " +
            "grep '^MemTotal:' /proc/meminfo; " +
            "grep '^MemAvailable:' /proc/meminfo; " +
            "nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo unavailable"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.updateStats(text)
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true

        onTriggered: {
            if (!statsProcess.running)
                statsProcess.running = true
        }
    }

    Component.onCompleted: {
        statsProcess.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // HEADER
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: "Hardware"
                    color: Config.Theme.text
                    font.pixelSize: 22
                    font.bold: true
                }

                Text {
                    text: "Live system performance"
                    color: Config.Theme.muted
                    font.pixelSize: 11
                }
            }

            Rectangle {
                radius: 20
                color: Qt.rgba(
                    Config.Theme.accent.r,
                    Config.Theme.accent.g,
                    Config.Theme.accent.b,
                    0.14
                )
                implicitWidth: liveLabel.implicitWidth + 18
                implicitHeight: 27

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#75d99a"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: liveLabel
                        text: "LIVE"
                        color: Config.Theme.accent
                        font.pixelSize: 10
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // CPU + GPU
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 148
            spacing: 10

            // CPU CARD
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Config.Theme.surface
                border.width: 1
                border.color: Config.Theme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "󰻠"
                            color: Config.Theme.accent
                            font.pixelSize: 21
                        }

                        Text {
                            text: "CPU"
                            color: Config.Theme.text
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    Text {
                        text: "Ryzen 5 7500F"
                        color: Config.Theme.text
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "6 cores · 12 threads"
                        color: Config.Theme.muted
                        font.pixelSize: 10
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Usage"
                            color: Config.Theme.muted
                            font.pixelSize: 10
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.cpuUsage < 0
                                ? "Sampling…"
                                : Math.round(root.cpuUsage) + "%"
                            color: Config.Theme.text
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 5
                        radius: 3
                        color: Config.Theme.border
                        clip: true

                        Rectangle {
                            width: parent.width *
                                (root.cpuUsage < 0 ? 0 : root.cpuUsage / 100)
                            height: parent.height
                            radius: 3
                            color: Config.Theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 350 }
                            }
                        }
                    }
                }
            }

            // GPU CARD
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Config.Theme.surface
                border.width: 1
                border.color: Config.Theme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "󰢮"
                            color: Config.Theme.accent
                            font.pixelSize: 21
                        }

                        Text {
                            text: "GPU"
                            color: Config.Theme.text
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    Text {
                        text: "RTX 5060"
                        color: Config.Theme.text
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Text {
                        text: root.gpuAvailable
                            ? root.gpuMemoryTotal.toFixed(1) + " GB VRAM"
                            : "8 GB VRAM"
                        color: Config.Theme.muted
                        font.pixelSize: 10
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Usage"
                            color: Config.Theme.muted
                            font.pixelSize: 10
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.gpuUsage < 0
                                ? "Unavailable"
                                : Math.round(root.gpuUsage) + "%"
                            color: Config.Theme.text
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 5
                        radius: 3
                        color: Config.Theme.border
                        clip: true

                        Rectangle {
                            width: parent.width *
                                (root.gpuUsage < 0 ? 0 : root.gpuUsage / 100)
                            height: parent.height
                            radius: 3
                            color: Config.Theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 350 }
                            }
                        }
                    }
                }
            }
        }

        // RAM CARD
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 108
            radius: 12
            color: Config.Theme.surface
            border.width: 1
            border.color: Config.Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 9

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "󰍛"
                        color: Config.Theme.accent
                        font.pixelSize: 22
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Memory"
                            color: Config.Theme.text
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            text: "32 GB DDR5"
                            color: Config.Theme.muted
                            font.pixelSize: 10
                        }
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: root.ramTotal > 0
                                ? root.ramUsed.toFixed(1) + " GB used"
                                : "Reading…"
                            color: Config.Theme.text
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            text: root.ramTotal > 0
                                ? root.ramUsage.toFixed(0) + "% in use"
                                : ""
                            color: Config.Theme.muted
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 7
                    radius: 4
                    color: Config.Theme.border
                    clip: true

                    Rectangle {
                        width: parent.width *
                            Math.max(0, Math.min(100, root.ramUsage)) / 100
                        height: parent.height
                        radius: 4
                        color: Config.Theme.accent

                        Behavior on width {
                            NumberAnimation { duration: 350 }
                        }
                    }
                }
            }
        }

        // GPU DETAILS
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 68
            radius: 12
            color: Config.Theme.surface
            border.width: 1
            border.color: Config.Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    text: "󰈸"
                    color: Config.Theme.accent
                    font.pixelSize: 23
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "GPU memory"
                        color: Config.Theme.text
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: root.gpuAvailable
                            ? root.gpuMemoryUsed.toFixed(1) + " GB / " +
                              root.gpuMemoryTotal.toFixed(1) + " GB"
                            : "Waiting for NVIDIA driver"
                        color: Config.Theme.muted
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: Config.Theme.border
                }

                ColumnLayout {
                    spacing: 4

                    Text {
                        text: root.gpuTemperature >= 0
                            ? root.gpuTemperature + " °C"
                            : "-- °C"
                        color: Config.Theme.text
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: "GPU temp"
                        color: Config.Theme.muted
                        font.pixelSize: 10
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
