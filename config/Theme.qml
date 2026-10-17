
pragma Singleton
import QtQuick
import "." as Config

QtObject {
    readonly property bool light: Config.Settings.themeMode === "light"
    readonly property bool dark: Config.Settings.themeMode === "dark"

    readonly property color background: light
        ? "#eee9e1"
        : dark
            ? "#111318"
            : Config.Colors.background

    readonly property color surface: light
        ? "#f8f4ed"
        : dark
            ? "#1b1d24"
            : Config.Colors.surface

    readonly property color text: light
        ? "#29252c"
        : dark
            ? "#e6e1e9"
            : Config.Colors.text

    readonly property color accent: Config.Colors.accent
    readonly property color border: Config.Colors.border
    readonly property color muted: Config.Colors.muted
}
