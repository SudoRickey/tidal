
import QtQuick
import "../modules"
import "../config" as ThemeConfig

Rectangle {
    id: bar

    width: parent.width
    height: parent.height

    radius: 14
    antialiasing: true
    clip: true

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
        0.75
    )

    Workspaces {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    Clock {
        anchors.centerIn: parent
    }
}
