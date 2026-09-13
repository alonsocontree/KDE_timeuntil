// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls

import "code/countdown.mjs" as Countdown

// A borderless, transparent window that shows one countdown on the desktop.
Window {
    id: window

    required property int index
    required property string eventId
    required property string eventName
    required property string eventDate
    required property string textColor
    required property int posX
    required property int posY
    required property bool locked
    required property string notifiedDate

    property var now: new Date()
    property bool canRemove: true

    signal editRequested()
    signal newRequested()

    title: eventName
    flags: Qt.FramelessWindowHint | Qt.Tool | Qt.WindowStaysOnBottomHint
    color: "transparent"
    visible: true

    width: Math.max(260, view.implicitWidth + 32)
    height: view.implicitHeight + 32
    // New events cascade from the top left corner until they are moved.
    x: posX >= 0 ? posX : 80 + index * 40
    y: posY >= 0 ? posY : 80 + index * 40

    // Stay visible when the user shows the desktop (Windows only).
    Component.onCompleted: DesktopPinner.pin(window)

    CountdownView {
        id: view

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        eventName: window.eventName || i18n("My event")
        eventDate: Countdown.parseEventDateTime(window.eventDate)
        now: window.now
        textColor: window.textColor
        secondaryColor: "#ffffff"
        secondaryFont.pixelSize: 15
        baseSize: 22
        // An outline keeps the text readable on light wallpapers and, unlike a
        // shader effect, also renders with the software backend.
        textStyle: Text.Outline
        textStyleColor: "#80000000"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton && !window.locked) {
                window.startSystemMove()
            }
        }
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                menu.popup()
            }
        }
    }

    // Save the position once the window stops moving.
    onXChanged: savePosition.restart()
    onYChanged: savePosition.restart()

    Timer {
        id: savePosition
        interval: 500
        onTriggered: EventStore.updateEvent(window.eventId, { posX: window.x, posY: window.y })
    }

    Menu {
        id: menu
        popupType: Popup.Native

        MenuItem {
            text: i18n("Edit…")
            onTriggered: window.editRequested()
        }
        MenuItem {
            text: i18n("New countdown")
            onTriggered: window.newRequested()
        }
        MenuItem {
            text: i18n("Lock position")
            checkable: true
            checked: window.locked
            onTriggered: EventStore.updateEvent(window.eventId, { locked: checked })
        }
        MenuItem {
            text: i18n("Remove")
            enabled: window.canRemove
            onTriggered: EventStore.removeEvent(window.eventId)
        }
        MenuSeparator {}
        MenuItem {
            text: i18n("Quit")
            onTriggered: Qt.quit()
        }
    }
}
