import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.dateandtime as DateAndTime

import "../code/countdown.mjs" as Countdown

KCM.SimpleKCM {
    id: page

    property alias cfg_eventName: eventNameField.text
    property string cfg_eventDate
    property alias cfg_daysColor: colorField.text

    // The configuration dialog also passes the default value of every entry.
    property string cfg_eventNameDefault
    property string cfg_eventDateDefault
    property string cfg_daysColorDefault

    readonly property var configuredDate: Countdown.parseEventDateTime(cfg_eventDate)
    // Where the pickers start: the configured date, or today at midnight.
    readonly property var pickerDate: configuredDate || new Date(new Date().setHours(0, 0, 0, 0))

    function syncColorCombo() {
        for (let i = 0; i < colorCombo.model.length; ++i) {
            if (colorCombo.model[i].value.toLowerCase() === colorField.text.toLowerCase()) {
                colorCombo.currentIndex = i
                return
            }
        }
        colorCombo.currentIndex = -1
    }

    Component.onCompleted: {
        syncColorCombo()
    }

    Kirigami.FormLayout {
        TextField {
            id: eventNameField
            Kirigami.FormData.label: i18n("Event name:")
            placeholderText: i18n("e.g. Vacation")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Date and time:")

            Button {
                icon.name: "view-calendar"
                text: page.configuredDate
                    ? page.configuredDate.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                    : i18n("Pick a date…")
                onClicked: datePopupComponent.createObject(Overlay.overlay, { value: page.pickerDate }).open()
            }

            Button {
                icon.name: "clock"
                text: page.pickerDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                // TimePopup keeps its own `_value`, which it only syncs when the
                // hour or minute changes, so a time of 00:00 needs it set too.
                onClicked: timePopupComponent.createObject(Overlay.overlay, {
                    value: page.pickerDate,
                    _value: page.pickerDate,
                }).open()
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Days color:")

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                Layout.preferredHeight: Kirigami.Units.gridUnit
                radius: Kirigami.Units.smallSpacing
                color: colorField.text
                border.width: 1
                border.color: "#808080"
            }

            ComboBox {
                id: colorCombo
                model: [
                    { text: i18n("White"), value: "#ffffff" },
                    { text: i18n("Black"), value: "#000000" },
                    { text: i18n("Red"), value: "#ff5555" },
                    { text: i18n("Orange"), value: "#ff9800" },
                    { text: i18n("Green"), value: "#4caf50" },
                    { text: i18n("Blue"), value: "#42a5f5" },
                    { text: i18n("Yellow"), value: "#ffd54f" }
                ]
                textRole: "text"
                onActivated: {
                    colorField.text = model[currentIndex].value
                }
            }

            TextField {
                id: colorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                placeholderText: "#ffffff"
                onTextChanged: syncColorCombo()
            }
        }
    }

    // The popups only read `value` when they are created, so make a new one
    // each time, like Kirigami Addons' FormDateTimeDelegate does.
    Component {
        id: datePopupComponent

        DateAndTime.DatePopup {
            anchors.centerIn: parent
            modal: true
            onAccepted: {
                const date = new Date(page.pickerDate.getTime())
                date.setFullYear(value.getFullYear(), value.getMonth(), value.getDate())
                page.cfg_eventDate = Countdown.toStorageString(date)
            }
            onClosed: destroy()
        }
    }

    Component {
        id: timePopupComponent

        DateAndTime.TimePopup {
            anchors.centerIn: parent
            onAccepted: {
                const date = new Date(page.pickerDate.getTime())
                date.setHours(value.getHours(), value.getMinutes(), 0, 0)
                page.cfg_eventDate = Countdown.toStorageString(date)
            }
            onClosed: destroy()
        }
    }
}
