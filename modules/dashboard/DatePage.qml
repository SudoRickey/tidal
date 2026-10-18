import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    property date displayedMonth: new Date(
        new Date().getFullYear(),
        new Date().getMonth(),
        1
    )
    property date selectedDate: new Date()
    property var notes: ({})
    property string noteText: ""
    property bool loadingNotes: true

    readonly property color accentColor: "#87d1eb"
    readonly property color textColor: "#dee3e6"
    readonly property color mutedColor: "#89969c"
    readonly property color surfaceColor: "#20272b"
    readonly property color editorColor: "#151a1d"
    readonly property color borderColor: "#3a484f"

    function dateKey(date) {
        return date.getFullYear() + "-"
            + String(date.getMonth() + 1).padStart(2, "0") + "-"
            + String(date.getDate()).padStart(2, "0")
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate()
    }

    function selectDay(date) {
        selectedDate = new Date(
            date.getFullYear(),
            date.getMonth(),
            date.getDate()
        )
        noteText = notes[dateKey(selectedDate)] || ""
    }

    function changeMonth(offset) {
        displayedMonth = new Date(
            displayedMonth.getFullYear(),
            displayedMonth.getMonth() + offset,
            1
        )
    }

    function saveNote() {
        if (loadingNotes)
            return

        let updated = Object.assign({}, notes)
        const key = dateKey(selectedDate)

        if (noteText.trim().length === 0)
            delete updated[key]
        else
            updated[key] = noteText

        notes = updated
        saveFile.setText(JSON.stringify(notes, null, 2))
        saveFile.write()
    }

    function loadNoteData() {
        try {
            const data = noteFile.text()
            notes = data.trim().length > 0
                ? JSON.parse(data)
                : ({})
        } catch (error) {
            notes = ({})
            console.warn("Tidal calendar: could not read notes:", error)
        }

        noteText = notes[dateKey(selectedDate)] || ""
        loadingNotes = false
    }

    FileView {
        id: noteFile
        path: Quickshell.env("HOME")
            + "/.local/share/tidal/calendar-notes.json"
        watchChanges: false

        onLoaded: root.loadNoteData()

        onLoadFailed: function(error) {
            root.notes = ({})
            root.noteText = ""
            root.loadingNotes = false
        }
    }

    FileView {
        id: saveFile
        path: Quickshell.env("HOME")
            + "/.local/share/tidal/calendar-notes.json"
    }

    Component.onCompleted: noteFile.reload()

    Column {
        anchors.fill: parent
        spacing: 4
        clip: true

        // Header
        Row {
            width: parent.width
            height: 32
            spacing: 4

            Text {
                width: parent.width - 76
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: "Calendar"
                color: root.textColor
                font.pixelSize: 21
                font.bold: true
            }

            Rectangle {
                width: 32
                height: 28
                radius: 7
                color: prevMouse.containsMouse
                    ? root.surfaceColor : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: root.textColor
                    font.pixelSize: 24
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.changeMonth(-1)
                }
            }

            Rectangle {
                width: 32
                height: 28
                radius: 7
                color: nextMouse.containsMouse
                    ? root.surfaceColor : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: root.textColor
                    font.pixelSize: 24
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.changeMonth(1)
                }
            }
        }

        // Month and year — no Today button
        Text {
            width: parent.width
            height: 22
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatDate(root.displayedMonth, "MMMM yyyy")
            color: root.accentColor
            font.pixelSize: 15
            font.bold: true
        }

        // Weekday labels
        Grid {
            width: parent.width
            columns: 7
            rowSpacing: 0

            Repeater {
                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                Text {
                    required property string modelData

                    width: root.width / 7
                    height: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: root.mutedColor
                    font.pixelSize: 10
                }
            }
        }

        // Compact calendar dates
        Grid {
            width: parent.width
            columns: 7
            rowSpacing: 1
            columnSpacing: 0

            Repeater {
                model: {
                    const first = new Date(
                        root.displayedMonth.getFullYear(),
                        root.displayedMonth.getMonth(),
                        1
                    )
                    const offset = (first.getDay() + 6) % 7
                    const count = new Date(
                        first.getFullYear(),
                        first.getMonth() + 1,
                        0
                    ).getDate()

                    return offset + count
                }

                Item {
                    required property int index

                    width: root.width / 7
                    height: 24

                    readonly property int dayNumber: {
                        const first = new Date(
                            root.displayedMonth.getFullYear(),
                            root.displayedMonth.getMonth(),
                            1
                        )
                        return index - ((first.getDay() + 6) % 7) + 1
                    }

                    readonly property bool validDay: dayNumber >= 1
                        && dayNumber <= new Date(
                            root.displayedMonth.getFullYear(),
                            root.displayedMonth.getMonth() + 1,
                            0
                        ).getDate()

                    readonly property date cellDate: new Date(
                        root.displayedMonth.getFullYear(),
                        root.displayedMonth.getMonth(),
                        dayNumber
                    )

                    Rectangle {
                        id: dayBackground
                        anchors.centerIn: parent
                        width: 23
                        height: 23
                        radius: 7

                        color: {
                            if (!parent.validDay)
                                return "transparent"

                            if (root.sameDay(
                                parent.cellDate,
                                root.selectedDate
                            ))
                                return root.accentColor

                            if (root.sameDay(parent.cellDate, new Date()))
                                return "#34464e"

                            return dayMouse.containsMouse
                                ? root.surfaceColor : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayBackground.parent.validDay
                                ? dayBackground.parent.dayNumber : ""

                            color: root.sameDay(
                                dayBackground.parent.cellDate,
                                root.selectedDate
                            ) ? "#10252d" : root.textColor

                            font.pixelSize: 10
                            font.bold: root.sameDay(
                                dayBackground.parent.cellDate,
                                root.selectedDate
                            )
                        }

                        Rectangle {
                            visible: dayBackground.parent.validDay
                                && Boolean(root.notes[
                                    root.dateKey(
                                        dayBackground.parent.cellDate
                                    )
                                ])

                            width: 3
                            height: 3
                            radius: 2

                            color: root.sameDay(
                                dayBackground.parent.cellDate,
                                root.selectedDate
                            ) ? "#10252d" : root.accentColor

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: dayBackground.parent.validDay

                            onClicked: root.selectDay(
                                dayBackground.parent.cellDate
                            )
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.borderColor
        }

        // Selected date
        Text {
            width: parent.width
            height: 20
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatDate(root.selectedDate, "ddd, d MMM")
            color: root.textColor
            font.pixelSize: 12
            font.bold: true
        }

        // Small notes box with its own rounded border
        Rectangle {
            id: editorFrame

            width: parent.width
            height: 48
            radius: 9
            color: root.editorColor

            border.width: 1
            border.color: notesEditor.activeFocus
                ? root.accentColor : root.borderColor

            clip: true

            TextArea {
                id: notesEditor

                anchors.fill: parent
                anchors.margins: 6

                text: root.noteText
                placeholderText: "Write a note..."
                color: root.textColor
                placeholderTextColor: root.mutedColor

                font.pixelSize: 12
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                activeFocusOnPress: true

                background: Item {}

                onTextChanged: {
                    if (root.noteText !== text)
                        root.noteText = text
                }

                Keys.onEscapePressed: focus = false
            }
        }

        // Save and clear
        Row {
            width: parent.width
            height: 28
            spacing: 8

            Rectangle {
                width: 82
                height: 28
                radius: 7
                color: saveMouse.containsMouse
                    ? "#a4e0f5" : root.accentColor

                Text {
                    anchors.centerIn: parent
                    text: "Save note"
                    color: "#10252d"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.saveNote()
                }
            }

            Rectangle {
                width: 64
                height: 28
                radius: 7

                color: clearMouse.containsMouse
                    ? root.surfaceColor : "transparent"

                border.width: 1
                border.color: root.borderColor

                Text {
                    anchors.centerIn: parent
                    text: "Clear"
                    color: root.mutedColor
                    font.pixelSize: 11
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        root.noteText = ""
                        notesEditor.text = ""
                        root.saveNote()
                    }
                }
            }

            Item {
                width: Math.max(0, parent.width - 170)
                height: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Local notes"
                color: root.mutedColor
                font.pixelSize: 10
            }
        }
    }
}
