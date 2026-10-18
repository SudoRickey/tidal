pragma Singleton

import QtQuick
import Quickshell.Io

Item {
    id: root

    property var colors: ({
        background: "#0f1416",
        surface: "#1b2023",
        text: "#dee3e6",
        accent: "#87d1eb",
        accentText: "#003543",
        border: "#8a9296",
        muted: "#bfc8cc"
    })

    FileView {
        id: colorFile

        path: "/home/rickey/.cache/matugen/colors.json"
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            try {
                root.colors = JSON.parse(text())
            } catch (e) {
                console.warn("Failed to load Matugen colors:", e)
            }
        }
}

    readonly property color background: colors.background
    readonly property color surface: colors.surface
    readonly property color text: colors.text
    readonly property color accent: colors.accent
    readonly property color accentText: colors.accentText
    readonly property color border: colors.border
    readonly property color muted: colors.muted
}
