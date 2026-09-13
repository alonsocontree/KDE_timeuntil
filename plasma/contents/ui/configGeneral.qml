import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: page

    property alias cfg_eventName: eventNameField.text
    property alias cfg_eventDate: eventDateField.text
    property alias cfg_daysColor: colorField.text

    // The configuration dialog also passes the default value of every entry.
    property string cfg_eventNameDefault
    property string cfg_eventDateDefault
    property string cfg_daysColorDefault

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
            Kirigami.FormData.label: i18n("Nombre del evento:")
            placeholderText: i18n("Ej: Vacaciones")
        }

        TextField {
            id: eventDateField
            Kirigami.FormData.label: i18n("Fecha (DD-MM-AAAA):")
            placeholderText: "31-12-2026"
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Color de dias:")

            Rectangle {
                width: Kirigami.Units.gridUnit * 2
                height: Kirigami.Units.gridUnit
                radius: Kirigami.Units.smallSpacing
                color: colorField.text
                border.width: 1
                border.color: "#808080"
            }

            ComboBox {
                id: colorCombo
                model: [
                    { text: i18n("Blanco"), value: "#ffffff" },
                    { text: i18n("Negro"), value: "#000000" },
                    { text: i18n("Rojo"), value: "#ff5555" },
                    { text: i18n("Naranja"), value: "#ff9800" },
                    { text: i18n("Verde"), value: "#4caf50" },
                    { text: i18n("Azul"), value: "#42a5f5" },
                    { text: i18n("Amarillo"), value: "#ffd54f" }
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
}
