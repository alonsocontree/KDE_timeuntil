import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Default values in case config entries do not exist yet.
    Plasmoid.configuration.eventName = Plasmoid.configuration.eventName || "Mi evento"
    Plasmoid.configuration.eventDate = Plasmoid.configuration.eventDate || Qt.formatDate(new Date(), "yyyy-MM-dd")

    readonly property int daysRemaining: calculateDaysRemaining(Plasmoid.configuration.eventDate)
    readonly property bool validDate: isValidDateString(Plasmoid.configuration.eventDate)

    function isValidDateString(dateString) {
        if (!dateString || !/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
            return false
        }

        const parts = dateString.split("-")
        const year = Number(parts[0])
        const month = Number(parts[1])
        const day = Number(parts[2])

        const parsed = new Date(Date.UTC(year, month - 1, day))
        return parsed.getUTCFullYear() === year
            && parsed.getUTCMonth() === (month - 1)
            && parsed.getUTCDate() === day
    }

    function calculateDaysRemaining(dateString) {
        if (!isValidDateString(dateString)) {
            return 0
        }

        const parts = dateString.split("-")
        const year = Number(parts[0])
        const month = Number(parts[1])
        const day = Number(parts[2])

        const now = new Date()
        const todayUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate())
        const targetUtc = Date.UTC(year, month - 1, day)
        const msPerDay = 24 * 60 * 60 * 1000

        return Math.floor((targetUtc - todayUtc) / msPerDay)
    }

    function humanDaysLabel() {
        if (!validDate) {
            return "Fecha invalida"
        }

        if (daysRemaining === 0) {
            return "Hoy"
        }

        if (daysRemaining > 0) {
            return daysRemaining + " dias"
        }

        return "Hace " + Math.abs(daysRemaining) + " dias"
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                ToolButton {
                    text: "Ajustes"
                    onClicked: settingsSheet.open()
                }
            }

            Label {
                Layout.fillWidth: true
                text: Plasmoid.configuration.eventName
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: humanDaysLabel()
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Kirigami.Units.gridUnit * 2
                font.weight: Font.DemiBold
            }

            Label {
                Layout.fillWidth: true
                text: "Fecha: " + Plasmoid.configuration.eventDate
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.75
            }

            Item { Layout.fillHeight: true }
        }

        Kirigami.OverlaySheet {
            id: settingsSheet
            parent: root

            property string draftEventName: Plasmoid.configuration.eventName
            property string draftEventDate: Plasmoid.configuration.eventDate

            onSheetOpenChanged: {
                if (sheetOpen) {
                    draftEventName = Plasmoid.configuration.eventName
                    draftEventDate = Plasmoid.configuration.eventDate
                } else {
                    Plasmoid.configuration.eventName = draftEventName.trim() || "Mi evento"
                    Plasmoid.configuration.eventDate = draftEventDate.trim() || Qt.formatDate(new Date(), "yyyy-MM-dd")
                }
            }

            header: Kirigami.Heading {
                text: "Ajustes"
                level: 3
            }

            contentItem: ColumnLayout {
                width: Kirigami.Units.gridUnit * 18
                spacing: Kirigami.Units.smallSpacing

                Label {
                    text: "Nombre del evento"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Ej: Vacaciones"
                    text: settingsSheet.draftEventName
                    onTextChanged: settingsSheet.draftEventName = text
                }

                Label {
                    text: "Fecha del evento (AAAA-MM-DD)"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "2026-12-31"
                    text: settingsSheet.draftEventDate
                    onTextChanged: settingsSheet.draftEventDate = text
                }

                Label {
                    Layout.fillWidth: true
                    visible: !root.isValidDateString(settingsSheet.draftEventDate)
                    color: Kirigami.Theme.negativeTextColor
                    text: "Formato invalido. Usa AAAA-MM-DD."
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
