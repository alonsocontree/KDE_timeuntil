// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQml.Models
import Qt.labs.platform as Platform

import "code/countdown.mjs" as Countdown

QtObject {
    id: app

    property var now: new Date()

    function openSettings(window) {
        settingsComponent.createObject(app, {
            eventId: window.eventId,
            eventName: window.eventName,
            eventDate: window.eventDate,
            textColor: window.textColor
        })
    }

    function addCountdown() {
        EventStore.addEvent()
        const window = windows.objectAt(windows.count - 1)
        if (window) {
            openSettings(window)
        }
    }

    // Notifies each event once, when its time arrives. See
    // Countdown.shouldNotify() for how late a notification may come.
    function checkNotifications(allowLate) {
        const now = new Date()
        for (let i = 0; i < windows.count; ++i) {
            const window = windows.objectAt(i)
            const target = window ? Countdown.parseEventDateTime(window.eventDate) : null
            if (!target || now.getTime() < target.getTime()) {
                continue
            }
            const alreadyNotified = window.notifiedDate === window.eventDate
            if (Countdown.shouldNotify(now, target, alreadyNotified, allowLate)) {
                tray.showMessage(window.eventName || i18n("My event"),
                                 i18n("The event started at %1.", target.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)))
            }
            if (!alreadyNotified) {
                EventStore.updateEvent(window.eventId, { notifiedDate: window.eventDate })
            }
        }
    }

    Component.onCompleted: Qt.callLater(app.checkNotifications, true)

    property Component settingsComponent: Component {
        SettingsDialog {}
    }

    // Refresh `now` at the start of every minute, like the Plasma widget.
    property Timer clock: Timer {
        running: true
        interval: Countdown.msUntilNextMinute(new Date())
        onTriggered: {
            app.now = new Date()
            app.checkNotifications(true)
            interval = Countdown.msUntilNextMinute(app.now)
            start()
        }
    }

    // A date picked in the past is only marked as notified.
    property Connections dateChanges: Connections {
        target: EventStore
        function onDataChanged(topLeft, bottomRight, roles) {
            if (roles.indexOf(EventStore.EventDateRole) >= 0) {
                Qt.callLater(app.checkNotifications, false)
            }
        }
    }

    property Platform.SystemTrayIcon tray: Platform.SystemTrayIcon {
        icon.source: "qrc:/icons/timeuntil.png"
        tooltip: "TimeUntil"
        // Shown once the icon is set, which avoids a "No Icon set" warning.
        Component.onCompleted: show()

        menu: Platform.Menu {
            Platform.MenuItem {
                text: i18n("New countdown")
                onTriggered: app.addCountdown()
            }
            Platform.MenuItem {
                text: i18n("Start with Windows")
                visible: Autostart.supported
                checkable: true
                checked: Autostart.enabled
                onTriggered: Autostart.enabled = checked
            }
            Platform.MenuSeparator {}
            Platform.MenuItem {
                text: i18n("Quit")
                onTriggered: Qt.quit()
            }
        }
    }

    // One window per event.
    property Instantiator windows: Instantiator {
        model: EventStore

        delegate: CountdownWindow {
            id: countdownWindow

            now: app.now
            canRemove: EventStore.count > 1
            onEditRequested: app.openSettings(countdownWindow)
            onNewRequested: app.addCountdown()
        }
    }
}
