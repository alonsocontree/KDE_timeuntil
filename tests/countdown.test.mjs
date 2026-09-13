import assert from "node:assert/strict";
import { test } from "node:test";

import {
    calendarDaysBetween,
    computeCountdown,
    msUntilNextMinute,
    parseEventDateTime,
    shouldNotify,
    toStorageString,
} from "../plasma/contents/code/countdown.mjs";

function at(text) {
    const date = parseEventDateTime(text);
    assert.ok(date, `invalid test date: ${text}`);
    return date;
}

test("parses the storage format", () => {
    const date = parseEventDateTime("2026-11-05T18:30");
    assert.deepEqual(
        [date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes()],
        [2026, 10, 5, 18, 30],
    );
});

test("parses the formats saved before 1.1 as midnight", () => {
    assert.equal(toStorageString(parseEventDateTime("05-11-2026")), "2026-11-05T00:00");
    assert.equal(toStorageString(parseEventDateTime(" 2026-11-05 ")), "2026-11-05T00:00");
});

test("rejects invalid dates", () => {
    const invalid = ["", "   ", null, undefined, "31-02-2026", "2026-13-01T10:00",
        "2026-11-05T24:00", "2026-11-05T10:60", "5-11-2026", "tomorrow"];
    for (const text of invalid) {
        assert.equal(parseEventDateTime(text), null, String(text));
    }
});

test("round-trips the storage format", () => {
    assert.equal(toStorageString(at("2026-01-02T03:04")), "2026-01-02T03:04");
});

test("counts calendar days between dates", () => {
    assert.equal(calendarDaysBetween(at("2026-09-30T23:59"), at("2026-10-10T00:00")), 10);
    assert.equal(calendarDaysBetween(at("2026-10-10T00:00"), at("2026-09-30T23:59")), -10);
});

test("counts whole days while at least a day is left", () => {
    assert.deepEqual(computeCountdown(at("2026-09-12T20:00"), at("2026-09-30T18:00")),
        { kind: "days", days: 17, hours: 0, minutes: 0 });
    assert.deepEqual(computeCountdown(at("2026-09-12T18:00"), at("2026-09-30T18:00")),
        { kind: "days", days: 18, hours: 0, minutes: 0 });
    assert.deepEqual(computeCountdown(at("2026-09-29T18:00"), at("2026-09-30T18:00")),
        { kind: "days", days: 1, hours: 0, minutes: 0 });
});

test("switches to hours and minutes on the last day", () => {
    assert.deepEqual(computeCountdown(at("2026-09-29T18:01"), at("2026-09-30T18:00")),
        { kind: "hours", days: 0, hours: 23, minutes: 59 });
    assert.deepEqual(computeCountdown(at("2026-09-30T12:40"), at("2026-09-30T18:00")),
        { kind: "hours", days: 0, hours: 5, minutes: 20 });
    assert.deepEqual(computeCountdown(at("2026-09-30T17:40"), at("2026-09-30T18:00")),
        { kind: "hours", days: 0, hours: 0, minutes: 20 });
});

test("ignores seconds like the minute-based display", () => {
    assert.deepEqual(computeCountdown(new Date(2026, 8, 30, 17, 59, 30), at("2026-09-30T18:00")),
        { kind: "hours", days: 0, hours: 0, minutes: 1 });
    assert.equal(computeCountdown(new Date(2026, 8, 30, 18, 0, 45), at("2026-09-30T18:00")).kind, "now");
});

test("reports today once the event started", () => {
    assert.equal(computeCountdown(at("2026-09-30T18:01"), at("2026-09-30T18:00")).kind, "today");
    assert.equal(computeCountdown(at("2026-09-30T23:59"), at("2026-09-30T18:00")).kind, "today");
});

test("counts calendar days after the event", () => {
    assert.deepEqual(computeCountdown(at("2026-10-01T00:05"), at("2026-09-30T23:00")),
        { kind: "daysAgo", days: 1, hours: 0, minutes: 0 });
    assert.deepEqual(computeCountdown(at("2026-10-10T12:00"), at("2026-09-30T18:00")),
        { kind: "daysAgo", days: 10, hours: 0, minutes: 0 });
});

test("keeps events saved before 1.1 working", () => {
    assert.deepEqual(computeCountdown(at("2026-09-12T20:00"), at("05-11-2026")),
        { kind: "days", days: 53, hours: 0, minutes: 0 });
    assert.deepEqual(computeCountdown(at("2026-11-04T10:00"), at("05-11-2026")),
        { kind: "hours", days: 0, hours: 14, minutes: 0 });
    assert.equal(computeCountdown(at("2026-11-05T09:00"), at("05-11-2026")).kind, "today");
});

test("notifies when the event starts", () => {
    const event = at("2026-09-30T18:00");
    assert.equal(shouldNotify(at("2026-09-30T17:59"), event, false, true), false);
    assert.equal(shouldNotify(new Date(2026, 8, 30, 18, 0, 0, 50), event, false, false), true);
    assert.equal(shouldNotify(new Date(2026, 8, 30, 18, 0, 59), event, false, false), true);
});

test("notifies late only when allowed and within a day", () => {
    const event = at("2026-09-30T18:00");
    assert.equal(shouldNotify(at("2026-09-30T20:00"), event, false, true), true);
    assert.equal(shouldNotify(at("2026-09-30T20:00"), event, false, false), false);
    assert.equal(shouldNotify(at("2026-10-01T18:00"), event, false, true), false);
});

test("never notifies twice or without a date", () => {
    assert.equal(shouldNotify(at("2026-09-30T18:00"), at("2026-09-30T18:00"), true, true), false);
    assert.equal(shouldNotify(at("2026-09-30T18:00"), null, false, true), false);
});

test("waits until the next minute starts", () => {
    assert.equal(msUntilNextMinute(new Date(2026, 0, 1, 10, 0, 30, 250)), 29800);
    assert.equal(msUntilNextMinute(new Date(2026, 0, 1, 10, 0, 0, 0)), 60050);
});
