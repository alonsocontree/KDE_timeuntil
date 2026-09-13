# Contributing

Thanks for your interest in KDE_timeuntil.

This project is intentionally minimal and considered feature-complete for its original purpose. Maintenance is very limited.

## What Is Welcome

- Critical bug fixes.
- Compatibility fixes for newer KDE Plasma 6 / Qt 6 versions.
- Small documentation corrections.

## Translation Contributions

My native language is Spanish, and the project started in Spanish-first wording.
An English translation file is included so contributors can help improve wording and clarity.

- Translation file: `po/en.po`
- Scope is intentionally small (the widget has very few strings).
- PRs with translation-only improvements are welcome.

## What Is Probably Out of Scope

- New features.
- Large UI redesigns.
- Refactors that do not solve a concrete issue.

## Before Opening a Pull Request

1. Check that the issue is reproducible.
2. Keep the patch as small as possible.
3. Test locally with:
   - `kpackagetool6 --type Plasma/Applet --upgrade plasma/`
   - `kquitapp6 plasmashell`
   - `plasmashell --replace >/dev/null 2>&1 & disown`
4. Confirm the widget still:
   - saves settings correctly,
   - parses the date in `DD-MM-YYYY`,
   - shows the days counter and event title.

## Pull Request Guidelines

- Use a clear title and short description.
- Explain what problem is being fixed.
- Include before/after screenshots for UI changes.
- Keep unrelated changes out of the same PR.

## Reporting Issues

When opening an issue, please include:

- KDE Plasma version
- Qt version
- Steps to reproduce
- Expected result
- Actual result
- Screenshots/logs if helpful

## Code of Conduct

Please be respectful and constructive in all interactions.
