#!/usr/bin/env bash
# Toolpath specialty folder icons — apply with fileicon (brew install fileicon)
# Adjust ICONS to wherever you saved the PNGs.
set -euo pipefail
ICONS="${1:-$HOME/Pictures/toolpath-folders}"

fileicon set "$HOME/Applications" "$ICONS/toolpath-folder-applications.png" 2>/dev/null \
  || sudo fileicon set /Applications "$ICONS/toolpath-folder-applications.png"
fileicon set "$HOME/Desktop"    "$ICONS/toolpath-folder-desktop.png"
fileicon set "$HOME/developer"  "$ICONS/toolpath-folder-developer.png"
fileicon set "$HOME/Documents"  "$ICONS/toolpath-folder-documents.png"
fileicon set "$HOME/Downloads"  "$ICONS/toolpath-folder-downloads.png"
fileicon set "$HOME/Movies"     "$ICONS/toolpath-folder-movies.png"
fileicon set "$HOME/Music"      "$ICONS/toolpath-folder-music.png"
fileicon set "$HOME/Pictures"   "$ICONS/toolpath-folder-pictures.png"
fileicon set "$HOME/Public"     "$ICONS/toolpath-folder-public.png"
echo "done — relaunch Finder (⌥ right-click Finder in Dock) if icons don't refresh"
