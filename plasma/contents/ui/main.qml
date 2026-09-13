import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    readonly property string eventName: (Plasmoid.configuration.eventName || "").trim() || i18n("My event")
    readonly property string eventDate: (Plasmoid.configuration.eventDate || "").trim() || "31-12-2026"
    readonly property color daysColor: (Plasmoid.configuration.daysColor || "#ffffff")
    readonly property bool validDate: isValidDateString(eventDate)
    readonly property int daysRemaining: calculateDaysRemaining(eventDate)

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function isValidDateString(dateString) {
        if (!dateString) {
            return false
        }

        let day = 0
        let month = 0
        let year = 0

        if (/^\d{2}-\d{2}-\d{4}$/.test(dateString)) {
            const parts = dateString.split("-")
            day = Number(parts[0])
            month = Number(parts[1])
            year = Number(parts[2])
        } else if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
            // Backward compatibility with previous saved format.
            const parts = dateString.split("-")
            year = Number(parts[0])
            month = Number(parts[1])
            day = Number(parts[2])
        } else {
            return false
        }

        const parsed = new Date(Date.UTC(year, month - 1, day))

        return parsed.getUTCFullYear() === year
            && parsed.getUTCMonth() === (month - 1)
            && parsed.getUTCDate() === day
    }

    function calculateDaysRemaining(dateString) {
        if (!isValidDateString(dateString)) {
            return 0
        }

        let day = 0
        let month = 0
        let year = 0

        if (/^\d{2}-\d{2}-\d{4}$/.test(dateString)) {
            const parts = dateString.split("-")
            day = Number(parts[0])
            month = Number(parts[1])
            year = Number(parts[2])
        } else {
            const parts = dateString.split("-")
            year = Number(parts[0])
            month = Number(parts[1])
            day = Number(parts[2])
        }

        const now = new Date()
        const todayUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate())
        const targetUtc = Date.UTC(year, month - 1, day)
        const msPerDay = 24 * 60 * 60 * 1000

        return Math.floor((targetUtc - todayUtc) / msPerDay)
    }

    function daysLabel() {
        if (!validDate) {
            return i18n("Invalid date")
        }

        if (daysRemaining === 0) {
            return i18n("Today")
        }

        if (daysRemaining > 0) {
            return i18n("%1 days", daysRemaining)
        }

        return i18n("%1 days ago", Math.abs(daysRemaining))
    }

    fullRepresentation: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            Label {
                Layout.fillWidth: true
                text: root.daysLabel()
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Kirigami.Units.gridUnit * 2
                font.weight: Font.DemiBold
                color: root.daysColor
            }

            Label {
                Layout.fillWidth: true
                text: root.eventName
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                opacity: 0.9
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
