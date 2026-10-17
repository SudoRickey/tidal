
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

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
        command: ["bash", "-c",
            "cat \"$HOME/.config/quickshell/state/current-wallpaper\" 2>/dev/null || true"]
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

            ColumnLayout {
                spacing: 3

                Text {
                    text: "Wallpaper"
                    color: "#f5f5f5"
                    font.pixelSize: 22
                    font.bold: true
                }
            }

            Item { Layout.fillWidth: true }

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

        Text {
            Layout.fillWidth: true
            text: root.selectedWallpaper
                  ? "Selected: " + root.selectedWallpaper.split("/").pop()
                  : "Choose a wallpaper below"
            color: "#c7d0d8"
            font.pixelSize: 12
            elide: Text.ElideMiddle
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
                    color: "#252a30"
                    border.width: root.selectedWallpaper === filePath ? 2 : 1
                    border.color: root.selectedWallpaper === filePath
                                  ? "#87d1eb" : "#424951"
                    clip: true

                    Image {
                        anchors {
                            fill: parent
                            margins: 3
                        }
                        source: fileUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 27
                        color: "#d9000000"

                        Text {
                            anchors {
                                fill: parent
                                leftMargin: 7
                                rightMargin: 7
                            }
                            verticalAlignment: Text.AlignVCenter
                            text: fileName
                            color: "white"
                            font.pixelSize: 11
                            elide: Text.ElideMiddle
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
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
