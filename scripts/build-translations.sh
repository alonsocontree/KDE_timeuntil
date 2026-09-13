#!/usr/bin/env bash
# Compiles po/*.po into the plasmoid package, where Plasma looks for them.
# The Windows app embeds the .po files directly and does not need this.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
domain="plasma_applet_org.kde.kde_timeuntil"

for po in "$root"/po/*.po; do
    lang="$(basename "$po" .po)"
    out="$root/plasma/contents/locale/$lang/LC_MESSAGES"
    mkdir -p "$out"
    msgfmt --check --output-file="$out/$domain.mo" "$po"
    echo "$lang -> ${out#"$root"/}/$domain.mo"
done
