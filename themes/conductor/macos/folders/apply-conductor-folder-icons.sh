#!/usr/bin/env bash
# Conductor specialty folder icons — apply with fileicon (brew install fileicon)
# Adjust ICONS to wherever you saved the PNGs.
set -euo pipefail
ICONS="${1:-$HOME/Pictures/conductor-folders}"

fileicon set "$HOME/Applications" "$ICONS/conductor-folder-applications.png" 2>/dev/null \
  || sudo fileicon set /Applications "$ICONS/conductor-folder-applications.png"
fileicon set "$HOME/Desktop"    "$ICONS/conductor-folder-desktop.png"
fileicon set "$HOME/developer"  "$ICONS/conductor-folder-developer.png"
fileicon set "$HOME/Documents"  "$ICONS/conductor-folder-documents.png"
fileicon set "$HOME/Downloads"  "$ICONS/conductor-folder-downloads.png"
fileicon set "$HOME/Movies"     "$ICONS/conductor-folder-movies.png"
fileicon set "$HOME/Music"      "$ICONS/conductor-folder-music.png"
fileicon set "$HOME/Pictures"   "$ICONS/conductor-folder-pictures.png"
fileicon set "$HOME/Public"     "$ICONS/conductor-folder-public.png"
echo "done — relaunch Finder (⌥ right-click Finder in Dock) if icons don't refresh"
