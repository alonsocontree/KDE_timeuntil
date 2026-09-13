# KDE_timeuntil

A countdown to an event, as a KDE Plasma 6 desktop widget and as a small
Windows app (TimeUntil). By Alonso Contreras.

![Widget](img/screenshot_widget.png)

## Features

- Days left until the event. On the last day it switches to hours and
  minutes, then shows "Now!", "Today!" and "N days ago".
- Date and time picked from a calendar and a time picker.
- The event's date and time under its name, formatted for your language.
- A notification when the event starts.
- Transparent background and a configurable text color.
- English and Spanish.

See [CHANGELOG.md](CHANGELOG.md) for what changed in each version.

## Plasma widget

Requires KDE Plasma 6. The settings page uses Kirigami Addons, which comes
with Plasma.

### Install

From a release, download `KDE_timeuntil-<version>.plasmoid` and either use
*Add Widgets → Get New → Install Widget From Local File*, or run:

```sh
kpackagetool6 --type Plasma/Applet --install KDE_timeuntil-<version>.plasmoid
```

From this repository (use `--install` the first time):

```sh
kpackagetool6 --type Plasma/Applet --upgrade plasma/
systemctl --user restart plasma-plasmashell
```

Plasma keeps using the old files until plasmashell restarts.

To try it in a window without touching the desktop:

```sh
plasmawindowed org.kde.kde_timeuntil
```

### Upgrading from 1.0

Existing widgets keep their event. Dates saved by 1.0 have no time, so they
count down to midnight; open the settings to add one.

## Windows app

Works on Windows 10 and 11.

### Download

- **Releases:** `TimeUntil-<version>-setup.exe` (installer) or
  `TimeUntil-<version>-windows.zip` (portable).
- **Latest build:** every push builds the app. Open the run on the
  [Actions page](https://github.com/alonsocontree/KDE_timeuntil/actions) and
  download `TimeUntil-windows-installer` or `TimeUntil-windows` from its
  *Artifacts* section (you need to be signed in to GitHub).

The installer is not signed, so Windows SmartScreen warns about it. Choose
*More info → Run anyway*. It installs for the current user and does not need
administrator rights.

### Use

- Each countdown is a window on the desktop. Drag it to move it.
- Right-click a countdown for *Edit…*, *New countdown*, *Lock position* (or
  *Unlock position* once locked), *Remove* and *Quit*.
- The notification area icon offers *New countdown*, *Start with Windows* and
  *Quit*. Windows 11 may hide new icons under the `^` arrow on the taskbar.
- Countdowns stay visible when you show the desktop (Win+D).

### Start with Windows

Either check *Automatically start TimeUntil* during installation, or turn on
*Start with Windows* in the notification area menu. Both use the same entry,
and uninstalling removes it.

Settings are stored under `HKEY_CURRENT_USER\Software\TimeUntil`.

## Development

### Layout

- `plasma/`: the Plasma widget package (`metadata.json`, `contents/`).
  - `contents/code/countdown.mjs`: countdown logic, shared with the Windows app.
  - `contents/ui/CountdownView.qml`: countdown text, shared with the Windows app.
- `windows/`: the Qt 6 app. Its CMake project compiles the shared files in.
- `po/`: translations used by both versions.
- `tests/`: unit tests for `countdown.mjs`.
- `scripts/`: translation, icon and packaging helpers.

### Tests

```sh
node --test 'tests/*.test.mjs'
```

### Windows app

Needs Qt 6.8 or later and CMake. It also builds and runs on Linux for
development; keeping windows visible on Win+D and starting with Windows only
work on Windows.

```sh
cmake -S windows -B build/windows
cmake --build build/windows
./build/windows/TimeUntil
```

### Continuous integration

`.github/workflows/ci.yml` runs on every push and pull request. It tests
`countdown.mjs` in several time zones, packages the `.plasmoid`, and builds the
Windows app, its portable folder and its installer.

CI builds the Windows app with Qt 6.8.3 LTS, because the released aqtinstall
cannot install Qt 6.11 yet
([miurahr/aqtinstall#959](https://github.com/miurahr/aqtinstall/issues/959)).

### Translations

1. `scripts/extract-messages.sh` updates `po/timeuntil.pot` and merges it into
   the `.po` files.
2. Translate `po/<language>.po`.
3. `scripts/build-translations.sh` compiles the files into the widget package.
   Commit the generated `.mo` too. The Windows app reads the `.po` files when
   it is built.

To check a language, run `LANGUAGE=es plasmawindowed org.kde.kde_timeuntil`
or `LANGUAGE=es ./build/windows/TimeUntil`.

### Releases

1. Update the version in `plasma/metadata.json` and `windows/CMakeLists.txt`,
   and add the release to `CHANGELOG.md`.
2. Push a tag such as `v1.1.0`. CI publishes the `.plasmoid`, the Windows
   installer and a portable zip as a GitHub release.

## License

Copyright (C) 2026 Alonso Contreras.

GPL-3.0-or-later. The Windows app includes Qt under the LGPLv3; see
`windows/installer/THIRD-PARTY-NOTICES.txt`.
