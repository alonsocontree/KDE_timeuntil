// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "code/countdown.mjs" as Countdown

// Edits one event. Nothing is saved until the user presses Save.
ApplicationWindow {
    id: dialog

    required property string eventId
    required property string eventName
    required property string eventDate
    required property string textColor

    readonly property var colorPresets: [
        { text: i18n("White"), value: "#ffffff" },
        { text: i18n("Black"), value: "#000000" },
        { text: i18n("Red"), value: "#ff5555" },
        { text: i18n("Orange"), value: "#ff9800" },
        { text: i18n("Green"), value: "#4caf50" },
        { text: i18n("Blue"), value: "#42a5f5" },
        { text: i18n("Yellow"), value: "#ffd54f" }
    ]

    function syncColorCombo() {
        colorCombo.currentIndex = colorPresets.findIndex(preset => preset.value === colorField.text.toLowerCase())
    }

    function save() {
        EventStore.updateEvent(eventId, {
            eventName: nameField.text.trim(),
            eventDate: Countdown.toStorageString(picker.selectedDate),
            textColor: colorField.text
        })
        close()
    }

    title: i18n("Countdown settings")
    flags: Qt.Dialog
    visible: true
    minimumWidth: content.implicitWidth + 48
    minimumHeight: content.implicitHeight + 48
    width: minimumWidth
    height: minimumHeight

    onClosing: Qt.callLater(dialog.destroy)

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        Label {
            text: i18n("Event name:")
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            Layout.preferredWidth: 320
            text: dialog.eventName
            placeholderText: i18n("e.g. Vacation")
            focus: true
            onAccepted: dialog.save()
        }

        Label {
            text: i18n("Date and time:")
        }

        DateTimePicker {
            id: picker
            Layout.fillWidth: true
            selectedDate: Countdown.parseEventDateTime(dialog.eventDate) || new Date(new Date().setHours(0, 0, 0, 0))
        }

        Label {
            text: i18n("Days color:")
        }

        RowLayout {
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 20
                radius: 4
                color: colorField.text
                border.width: 1
                border.color: "#808080"
            }

            ComboBox {
                id: colorCombo
                Layout.fillWidth: true
                model: dialog.colorPresets
                textRole: "text"
                onActivated: colorField.text = dialog.colorPresets[currentIndex].value
            }

            TextField {
                id: colorField
                Layout.preferredWidth: 90
                text: dialog.textColor
                placeholderText: "#ffffff"
                onTextChanged: dialog.syncColorCombo()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.topMargin: 8

            Button {
                text: i18n("Cancel")
                onClicked: dialog.close()
            }

            Button {
                text: i18n("Save")
                highlighted: true
                onClicked: dialog.save()
            }
        }
    }

    Component.onCompleted: syncColorCombo()
}
