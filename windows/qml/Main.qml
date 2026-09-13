// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQml.Models

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

    property Component settingsComponent: Component {
        SettingsDialog {}
    }

    // Refresh `now` at the start of every minute, like the Plasma widget.
    property Timer clock: Timer {
        running: true
        interval: Countdown.msUntilNextMinute(new Date())
        onTriggered: {
            app.now = new Date()
            interval = Countdown.msUntilNextMinute(app.now)
            start()
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
