// SPDX-License-Identifier: GPL-3.0-or-later
//
// Countdown logic shared by the Plasma widget and the Windows app.
// There is no i18n here on purpose: the QML views turn results into text.

const MS_PER_MINUTE = 60 * 1000;
const MS_PER_DAY = 24 * 60 * MS_PER_MINUTE;

function pad(value) {
    return value < 10 ? "0" + value : String(value);
}

function localDate(year, month, day, hours, minutes) {
    const date = new Date(year, month - 1, day, hours, minutes, 0, 0);
    // Reject dates that JavaScript would silently roll over, like 31-02-2026.
    if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
        return null;
    }
    return date;
}

function floorToMinute(date) {
    const result = new Date(date.getTime());
    result.setSeconds(0, 0);
    return result;
}

function addDays(date, days) {
    const result = new Date(date.getTime());
    result.setDate(result.getDate() + days);
    return result;
}

// Parses the stored event date. Accepts "yyyy-MM-ddTHH:mm" and the formats
// saved before version 1.1 ("dd-MM-yyyy" and "yyyy-MM-dd"), which mean
// midnight. Returns a local Date, or null when the text is not a valid date.
export function parseEventDateTime(text) {
    const value = String(text === undefined || text === null ? "" : text).trim();

    let match = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$/.exec(value);
    if (match) {
        const hours = Number(match[4]);
        const minutes = Number(match[5]);
        if (hours > 23 || minutes > 59) {
            return null;
        }
        return localDate(Number(match[1]), Number(match[2]), Number(match[3]), hours, minutes);
    }

    match = /^(\d{2})-(\d{2})-(\d{4})$/.exec(value);
    if (match) {
        return localDate(Number(match[3]), Number(match[2]), Number(match[1]), 0, 0);
    }

    match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
    if (match) {
        return localDate(Number(match[1]), Number(match[2]), Number(match[3]), 0, 0);
    }

    return null;
}

// Formats a Date the way parseEventDateTime() reads it, in local time.
export function toStorageString(date) {
    return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate())
        + "T" + pad(date.getHours()) + ":" + pad(date.getMinutes());
}

// Calendar days from one date to another, ignoring the time of day.
export function calendarDaysBetween(from, to) {
    const fromDay = Date.UTC(from.getFullYear(), from.getMonth(), from.getDate());
    const toDay = Date.UTC(to.getFullYear(), to.getMonth(), to.getDate());
    return Math.round((toDay - fromDay) / MS_PER_DAY);
}

// Describes how far away the event is, in whole minutes like the display:
//   "days"     at least one full day left; `days` holds the whole days
//   "hours"    less than a day left; `hours` and `minutes`
//   "now"      the event starts this minute
//   "today"    the event started earlier today
//   "daysAgo"  the event was `days` calendar days ago
export function computeCountdown(now, target) {
    const current = floorToMinute(now);
    const event = floorToMinute(target);
    const remaining = event.getTime() - current.getTime();

    if (remaining > 0) {
        if (addDays(current, 1).getTime() <= event.getTime()) {
            // Step through calendar days so a day with a DST change still counts as one.
            let days = calendarDaysBetween(current, event);
            if (addDays(current, days).getTime() > event.getTime()) {
                days -= 1;
            }
            return { kind: "days", days: days, hours: 0, minutes: 0 };
        }
        const totalMinutes = Math.round(remaining / MS_PER_MINUTE);
        return { kind: "hours", days: 0, hours: Math.floor(totalMinutes / 60), minutes: totalMinutes % 60 };
    }

    if (remaining === 0) {
        return { kind: "now", days: 0, hours: 0, minutes: 0 };
    }

    const daysAgo = calendarDaysBetween(event, current);
    if (daysAgo === 0) {
        return { kind: "today", days: 0, hours: 0, minutes: 0 };
    }
    return { kind: "daysAgo", days: daysAgo, hours: 0, minutes: 0 };
}

// Milliseconds until the next minute starts, plus a small margin so a timer
// never fires just before the boundary.
export function msUntilNextMinute(now) {
    return MS_PER_MINUTE - (now.getSeconds() * 1000 + now.getMilliseconds()) + 50;
}
