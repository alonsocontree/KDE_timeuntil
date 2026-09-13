// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// A month calendar with hour and minute tumblers.
ColumnLayout {
    id: picker

    // The local date and time being edited.
    property var selectedDate: new Date()

    // The month shown in the calendar.
    property int shownYear: selectedDate.getFullYear()
    property int shownMonth: selectedDate.getMonth()

    property bool completed: false

    function setDay(year, month, day) {
        const date = new Date(selectedDate.getTime())
        date.setFullYear(year, month, day)
        selectedDate = date
    }

    function setTime(hours, minutes) {
        const date = new Date(selectedDate.getTime())
        date.setHours(hours, minutes, 0, 0)
        selectedDate = date
    }

    function showMonth(offset) {
        const date = new Date(shownYear, shownMonth + offset, 1)
        shownYear = date.getFullYear()
        shownMonth = date.getMonth()
    }

    spacing: 8

    Component.onCompleted: {
        hoursTumbler.currentIndex = selectedDate.getHours()
        minutesTumbler.currentIndex = selectedDate.getMinutes()
        completed = true
    }

    RowLayout {
        Layout.fillWidth: true

        ToolButton {
            text: "‹"
            font.pixelSize: 20
            Accessible.name: i18n("Previous month")
            onClicked: picker.showMonth(-1)
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.locale().standaloneMonthName(picker.shownMonth) + " " + picker.shownYear
            font.bold: true
        }

        ToolButton {
            text: "›"
            font.pixelSize: 20
            Accessible.name: i18n("Next month")
            onClicked: picker.showMonth(1)
        }
    }

    DayOfWeekRow {
        Layout.fillWidth: true
        locale: grid.locale
    }

    MonthGrid {
        id: grid

        Layout.fillWidth: true
        month: picker.shownMonth
        year: picker.shownYear
        locale: Qt.locale()

        // The day, month and year roles avoid converting QDate to a JavaScript
        // Date, which happens at UTC midnight and can land on the day before.
        delegate: Label {
            id: dayLabel

            required property int day
            required property int month
            required property int year
            required property bool today

            readonly property bool selected: day === picker.selectedDate.getDate()
                && month === picker.selectedDate.getMonth()
                && year === picker.selectedDate.getFullYear()

            text: day
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            padding: 6
            font.bold: today
            opacity: month === grid.month ? 1 : 0.45
            color: selected ? palette.highlightedText : palette.windowText

            background: Rectangle {
                radius: 4
                color: dayLabel.selected ? dayLabel.palette.highlight : "transparent"
                border.width: dayLabel.today && !dayLabel.selected ? 1 : 0
                border.color: dayLabel.palette.highlight
            }

            TapHandler {
                onTapped: picker.setDay(dayLabel.year, dayLabel.month, dayLabel.day)
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 4

        Label {
            text: i18n("Time:")
            Layout.rightMargin: 8
        }

        Tumbler {
            id: hoursTumbler
            model: 24
            visibleItemCount: 3
            implicitWidth: 56
            implicitHeight: 110
            delegate: tumblerDelegate
            onCurrentIndexChanged: {
                if (picker.completed) {
                    picker.setTime(currentIndex, minutesTumbler.currentIndex)
                }
            }
        }

        Label {
            text: ":"
            font.bold: true
        }

        Tumbler {
            id: minutesTumbler
            model: 60
            visibleItemCount: 3
            implicitWidth: 56
            implicitHeight: 110
            delegate: tumblerDelegate
            onCurrentIndexChanged: {
                if (picker.completed) {
                    picker.setTime(hoursTumbler.currentIndex, currentIndex)
                }
            }
        }
    }

    Component {
        id: tumblerDelegate

        Label {
            required property int index
            required property int modelData

            text: modelData < 10 ? "0" + modelData : modelData
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 18
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
        }
    }
}
