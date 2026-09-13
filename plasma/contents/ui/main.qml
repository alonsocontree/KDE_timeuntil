import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.notification
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

    // Stored date that was already notified in this session. The settings
    // dialog can write an older notifiedEventDate back, so do not rely on
    // the configuration alone.
    property string notifiedInSession: ""
    property bool ready: false

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Timer {
        running: true
        interval: Countdown.msUntilNextMinute(new Date())
        onTriggered: {
            root.now = new Date()
            root.checkNotification(true)
            interval = Countdown.msUntilNextMinute(root.now)
            start()
        }
    }

    // Notifies once per configured date and remembers it. See
    // Countdown.shouldNotify() for when a notification is sent.
    function checkNotification(allowLate) {
        const stored = Plasmoid.configuration.eventDate
        if (!root.eventDate || root.now.getTime() < root.eventDate.getTime()) {
            return
        }
        const alreadyNotified = Plasmoid.configuration.notifiedEventDate === stored
            || root.notifiedInSession === stored
        if (Countdown.shouldNotify(root.now, root.eventDate, alreadyNotified, allowLate)) {
            eventNotification.sendEvent()
        }
        root.notifiedInSession = stored
        if (Plasmoid.configuration.notifiedEventDate !== stored) {
            Plasmoid.configuration.notifiedEventDate = stored
        }
    }

    onEventDateChanged: {
        if (ready) {
            checkNotification(false)
        }
    }

    Component.onCompleted: {
        checkNotification(true)
        ready = true
    }

    Notification {
        id: eventNotification
        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "view-calendar"
        title: root.eventName
        text: root.eventDate
            ? i18n("The event started at %1.", root.eventDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat))
            : ""
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
