#!/usr/bin/env bash
# Renders windows/resources/timeuntil.svg into the PNG and ICO files that
# the Windows app uses. Needs rsvg-convert and ImageMagick.
set -euo pipefail

dir="$(cd "$(dirname "$0")/../windows/resources" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

sizes=(16 24 32 48 64 128 256)
for size in "${sizes[@]}"; do
    rsvg-convert -w "$size" -h "$size" "$dir/timeuntil.svg" -o "$tmp/$size.png"
done
cp "$tmp/256.png" "$dir/timeuntil.png"
files=()
for size in "${sizes[@]}"; do
    files+=("$tmp/$size.png")
done
magick "${files[@]}" "$dir/timeuntil.ico"
