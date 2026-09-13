// Daylight saving time cases. New York switches on 8 March 2026 (02:00 -> 03:00)
// and on 1 November 2026 (02:00 -> 01:00).
process.env.TZ = "America/New_York";

import assert from "node:assert/strict";
import { test } from "node:test";

import { computeCountdown, parseEventDateTime } from "../plasma/contents/code/countdown.mjs";

function at(text) {
    const date = parseEventDateTime(text);
    assert.ok(date, `invalid test date: ${text}`);
    return date;
}

test("a 23-hour day still counts as one day", () => {
    assert.deepEqual(computeCountdown(at("2026-03-07T12:00"), at("2026-03-08T12:00")),
        { kind: "days", days: 1, hours: 0, minutes: 0 });
});

test("a 25-hour day still counts as one day", () => {
    assert.deepEqual(computeCountdown(at("2026-10-31T12:00"), at("2026-11-01T12:00")),
        { kind: "days", days: 1, hours: 0, minutes: 0 });
});

test("hours show the real time left across the change", () => {
    assert.deepEqual(computeCountdown(at("2026-03-08T01:00"), at("2026-03-08T04:00")),
        { kind: "hours", days: 0, hours: 2, minutes: 0 });
    assert.deepEqual(computeCountdown(at("2026-11-01T00:30"), at("2026-11-01T03:00")),
        { kind: "hours", days: 0, hours: 3, minutes: 30 });
});
