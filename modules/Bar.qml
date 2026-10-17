import QtQuick
import "../modules"
import "../config" as ThemeConfig

Rectangle {
    width: parent.width
    height: parent.height

    radius: 14
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

    Volume {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }
}
