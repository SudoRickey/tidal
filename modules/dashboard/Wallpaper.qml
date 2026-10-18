
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import "../../config" as Config

Item {
    id: root

    property string selectedWallpaper: ""
    property string wallpaperDirectory: "file:///home/rickey/Pictures/Wallpapers"

    Process {
        id: applyProcess
        command: ["bash", "/home/rickey/.config/quickshell/scripts/set-wallpaper.sh", ""]
    }

    FolderListModel {
        id: wallpapers
        folder: root.wallpaperDirectory
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.avif"]
        showDirs: false
        showFiles: true
        sortField: FolderListModel.Name
    }

    Component.onCompleted: {
        loadSavedProcess.running = true
    }

    Process {
        id: loadSavedProcess
        command: [
            "bash", "-c",
            "cat \"$HOME/.config/quickshell/state/current-wallpaper\" 2>/dev/null || true"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.selectedWallpaper = text.trim()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Wallpaper"
                color: Config.Theme.text
                font.pixelSize: 22
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: "Refresh"

                onClicked: {
                    wallpapers.folder = ""
                    Qt.callLater(function() {
                        wallpapers.folder = root.wallpaperDirectory
                    })
                }
            }
        }

        GridView {
            id: gallery

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            cellWidth: 156
            cellHeight: 118
            model: wallpapers

            ScrollBar.vertical: ScrollBar {}

            delegate: Item {
                required property string fileName
                required property string filePath
                required property url fileUrl

                width: gallery.cellWidth
                height: gallery.cellHeight

                Rectangle {
                    anchors {
                        fill: parent
                        margins: 5
                    }

                    radius: 8
                    color: Config.Theme.surface

                    border.width: root.selectedWallpaper === filePath ? 2 : 1
                    border.color: root.selectedWallpaper === filePath
                        ? Config.Theme.accent
                        : Config.Theme.border

                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 3

                        source: fileUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.selectedWallpaper = filePath

                            applyProcess.command = [
                                "bash",
                                "/home/rickey/.config/quickshell/scripts/set-wallpaper.sh",
                                filePath
                            ]

                            applyProcess.running = true
                        }
                    }
                }
            }
        }
    }
}
