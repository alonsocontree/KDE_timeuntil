#!/usr/bin/env bash
# Builds dist/KDE_timeuntil-<version>.plasmoid, the zip format used by the
# KDE Store and by "Install Widget from Local File".
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="$(sed -n 's/.*"Version": *"\([^"]*\)".*/\1/p' "$root/plasma/metadata.json")"
out="$root/dist/KDE_timeuntil-$version.plasmoid"

mkdir -p "$root/dist"
rm -f "$out"
(cd "$root/plasma" && zip -qr "$out" .)
echo "${out#"$root"/}"
