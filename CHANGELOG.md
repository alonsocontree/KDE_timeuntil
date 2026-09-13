# Changelog

## 1.1.0 (2026-09-12)

### Plasma widget

- Fixed: the settings page did not accept input until another page had been
  opened.
- Fixed: the day count only refreshed when plasmashell started, so it was
  wrong after midnight or after a suspend. It now updates every minute.
- The event has a time as well as a date, picked from a calendar and a time
  picker.
- Adaptive countdown: days while at least a day is left, then hours and
  minutes, "Now!", "Today!" and "N days ago".
- The event's date and time appear under its name.
- A notification when the event starts.
- Proper singular and plural forms, English source text and a Spanish
  translation.
- Dates saved by 1.0 keep working and count down to midnight.

### Windows app

- New: TimeUntil for Windows 10 and 11, sharing the widget's countdown logic,
  text and translations.
- One window per countdown, with a settings dialog, notifications, a
  notification area icon and an option to start with Windows.
- Countdowns stay visible when showing the desktop (Win+D).
- Installer and portable zip.

## 1.0.0 (2026-04-12)

- First release of the Plasma widget.
