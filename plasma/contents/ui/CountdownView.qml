// SPDX-License-Identifier: GPL-3.0-or-later
//
// Countdown text shared by the Plasma widget and the Windows app. It only
// uses QtQuick so both can load it; each host provides i18n() and sizes.
import QtQuick
import QtQuick.Layouts

import "../code/countdown.mjs" as Countdown

ColumnLayout {
    id: view

    property string eventName
    // Local Date of the event, or null when there is no valid date.
    property var eventDate: null
    property var now: new Date()
    property color textColor: "white"
    property color secondaryColor: textColor
    property font secondaryFont: Qt.application.font
    // Base size in pixels for the big countdown text.
    property real baseSize: 18
    // Optional text style, e.g. Text.Outline to stay readable on any wallpaper.
    property int textStyle: Text.Normal
    property color textStyleColor: "black"

    readonly property var countdown: eventDate ? Countdown.computeCountdown(now, eventDate) : null

    function countdownText() {
        if (!countdown) {
            return i18n("Pick a date in the settings")
        }
        switch (countdown.kind) {
        case "days":
            return i18np("%1 day", "%1 days", countdown.days)
        case "hours":
            if (countdown.hours === 0) {
                return i18n("%1 min", countdown.minutes)
            }
            if (countdown.minutes === 0) {
                return i18n("%1 h", countdown.hours)
            }
            return i18n("%1 h %2 min", countdown.hours, countdown.minutes)
        case "now":
            return i18n("Now!")
        case "today":
            return i18n("Today!")
        default:
            return i18np("%1 day ago", "%1 days ago", countdown.days)
        }
    }

    spacing: Math.round(baseSize / 4)

    Text {
        Layout.fillWidth: true
        text: view.countdownText()
        color: view.textColor
        font.pixelSize: Math.round(view.countdown ? view.baseSize * 2 : view.baseSize)
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        style: view.textStyle
        styleColor: view.textStyleColor
    }

    Text {
        Layout.fillWidth: true
        text: view.eventName
        color: view.secondaryColor
        opacity: 0.9
        font: view.secondaryFont
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        style: view.textStyle
        styleColor: view.textStyleColor
    }

    Text {
        Layout.fillWidth: true
        visible: !!view.eventDate
        text: view.eventDate
            ? i18nc("@info event date and time", "%1 · %2",
                    view.eventDate.toLocaleDateString(Qt.locale(), i18nc("@info date format, see QDate::toString", "d MMM yyyy")),
                    view.eventDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat))
            : ""
        color: view.secondaryColor
        opacity: 0.7
        font: view.secondaryFont
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        style: view.textStyle
        styleColor: view.textStyleColor
    }
}
