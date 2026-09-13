import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import "../code/countdown.mjs" as Countdown

PlasmoidItem {
    id: root

    readonly property string eventName: (Plasmoid.configuration.eventName || "").trim() || i18n("My event")
    readonly property var eventDate: Countdown.parseEventDateTime(Plasmoid.configuration.eventDate)
    readonly property color daysColor: Plasmoid.configuration.daysColor || "#ffffff"

    // Bindings do not notice the clock moving, so `now` is refreshed at the
    // start of every minute.
    property var now: new Date()

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Timer {
        running: true
        interval: Countdown.msUntilNextMinute(new Date())
        onTriggered: {
            root.now = new Date()
            interval = Countdown.msUntilNextMinute(root.now)
            start()
        }
    }

    fullRepresentation: Item {
        anchors.fill: parent

        CountdownView {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            eventName: root.eventName
            eventDate: root.eventDate
            now: root.now
            textColor: root.daysColor
            secondaryColor: Kirigami.Theme.textColor
            baseSize: Kirigami.Units.gridUnit
        }
    }
}
