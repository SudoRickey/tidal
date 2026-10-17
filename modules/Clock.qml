import QtQuick

Text {
    id: clock

    text: Qt.formatDateTime(new Date(), "HH:mm")
    color: "#f5f5f5"

    font.pixelSize: 22
    font.weight: Font.Medium
    font.letterSpacing: 1

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            clock.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }
}
