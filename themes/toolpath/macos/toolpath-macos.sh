#!/usr/bin/env bash
# Toolpath · macOS setup — Rev H · JDC
# Applies the system-level pieces macOS actually lets us theme.
# Review before running; each section is independent.

set -euo pipefail

# ---- SELECTION / HIGHLIGHT: Dykem blue ----------------------------------
# macOS accepts a custom highlight even though the Settings UI only shows
# presets. Floats are #5B8FBF. Takes effect in new apps; log out for all.
defaults write NSGlobalDomain AppleHighlightColor -string "0.357 0.561 0.749 Other"

# ---- ACCENT --------------------------------------------------------------
# Accent (buttons, menus, focus rings) only takes Apple's presets — no
# custom hex. Orange is the nearest neighbor to bearing bronze; Blue is
# the nearest to Dykem. Pick one:
defaults write NSGlobalDomain AppleAccentColor -int 1     # 1 = Orange (~bronze)
# defaults write NSGlobalDomain AppleAccentColor -int 4   # 4 = Blue  (~dykem)

# ---- DARK MODE = SHOP FLOOR ---------------------------------------------
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# ---- WALLPAPER -----------------------------------------------------------
# Adjust the path to wherever you saved the PNGs.
WALL="$HOME/Pictures/toolpath-desktop-shop-floor.png"
if [ -f "$WALL" ]; then
  osascript -e "tell app \"System Events\" to set picture of every desktop to \"$WALL\""
fi

# ---- FOLDER ICONS --------------------------------------------------------
# Requires: brew install fileicon
# Tag the directories you want carrying the identity:
# fileicon set ~/developer         ~/Pictures/toolpath-folder.png
# fileicon set ~/developer/src     ~/Pictures/toolpath-folder.png
# Revert any time with: fileicon rm <dir>

echo "Done. Log out/in for highlight + accent to apply everywhere."
