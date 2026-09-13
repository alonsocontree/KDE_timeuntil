# Contributing

Thanks for your interest in KDE_timeuntil.

The project is small and maintained in spare time, so focused pull requests
are the easiest to review.

## What Is Welcome

- Bug fixes for the Plasma widget or the Windows app.
- Compatibility fixes for newer Plasma, Qt or Windows versions.
- Translations.
- Documentation fixes.

For new features, please open an issue first.

## Translations

Source strings are in English. The Spanish translation is `po/es.po`.

1. Run `scripts/extract-messages.sh`.
2. Copy `po/timeuntil.pot` to `po/<language>.po` (or edit an existing file)
   and translate it.
3. Run `scripts/build-translations.sh`, and commit the `.po` file together
   with the generated `.mo`.

For now, the Windows app only supports languages whose plural rule is
`n != 1`.

## Before Opening a Pull Request

1. Run the unit tests: `node --test 'tests/*.test.mjs'`.
2. For the Plasma widget:
   - `kpackagetool6 --type Plasma/Applet --upgrade plasma/`
   - `systemctl --user restart plasma-plasmashell`
   - Check that the settings page accepts input, the date and time pickers
     save, and the countdown updates.
   - `journalctl --user -b | grep kde_timeuntil` should show no QML errors.
3. For the Windows app, build it (see the README) and check the countdown
   windows, the settings dialog and the tray menu. Keeping windows visible
   on Win+D can only be tested on Windows.
4. Write commit messages following Conventional Commits, such as
   `feat(plasma): ...` or `fix(windows): ...`.

## Pull Request Guidelines

- Use a clear title and a short description of the problem being fixed.
- Include before and after screenshots for UI changes.
- Keep unrelated changes out of the same pull request.

## Reporting Issues

Please include:

- Plasma and Qt versions, or the Windows version
- Steps to reproduce
- Expected result
- Actual result
- Screenshots or logs if helpful

## Code of Conduct

Please be respectful and constructive in all interactions.
