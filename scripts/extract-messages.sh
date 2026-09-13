#!/usr/bin/env bash
# Extracts translatable strings from the QML sources into po/timeuntil.pot
# and merges them into every po/*.po file.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
mkdir -p po

sources=()
for dir in plasma/contents windows/qml; do
    if [[ -d "$dir" ]]; then
        while IFS= read -r file; do
            sources+=("$file")
        done < <(find "$dir" -name '*.qml' | sort)
    fi
done

# Same keywords KDE uses for QML (xgettext's C parser copes with QML syntax).
xgettext --from-code=UTF-8 -C --kde \
    -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
    --package-name=KDE_timeuntil \
    --msgid-bugs-address=https://github.com/alonsocontree/KDE_timeuntil/issues \
    --output=po/timeuntil.pot "${sources[@]}"

for po in po/*.po; do
    [[ -e "$po" ]] || continue
    msgmerge --quiet --update --backup=none "$po" po/timeuntil.pot
done
