#!/usr/bin/env bash
# Conductor · macOS setup — Rev H · JDC
# Applies the system-level pieces macOS actually lets us theme.
# Review before running; each section is independent.

set -euo pipefail

# ---- SELECTION / HIGHLIGHT: Sodium ---------------------------------------
# macOS accepts a custom highlight even though the Settings UI only shows
# presets. Floats are #F2A33C. Takes effect in new apps; log out for all.
defaults write NSGlobalDomain AppleHighlightColor -string "0.949 0.639 0.235 Other"

# ---- ACCENT --------------------------------------------------------------
# Accent (buttons, menus, focus rings) only takes Apple's presets — no
# custom hex. Orange is the nearest neighbor to sodium.
defaults write NSGlobalDomain AppleAccentColor -int 1     # 1 = Orange (~sodium)

# ---- DARK MODE = MOFFAT --------------------------------------------------
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# ---- WALLPAPER -----------------------------------------------------------
# Adjust the path to wherever you saved the PNGs. Variants:
#   conductor-desktop-moffat.png        3456x2234 (14" MacBook Pro)
#   conductor-desktop-moffat-16x9.png   5120x2880 (5K / Studio Display)
#   conductor-desktop-moffat-uw.png     5120x2160 (ultrawide)
#   conductor-desktop-stainless*.png    the light shade, same sizes
WALL="$HOME/Pictures/conductor-desktop-moffat.png"
if [ -f "$WALL" ]; then
  osascript -e "tell app \"System Events\" to set picture of every desktop to \"$WALL\""
fi

# ---- FOLDER ICONS --------------------------------------------------------
# Requires: brew install fileicon
# Specialty folders (Applications, Desktop, developer, Documents…):
#   bash themes/conductor/macos/folders/apply-conductor-folder-icons.sh ~/Pictures/conductor-folders
# Generic icon for any other directory:
# fileicon set ~/builds  ~/Pictures/conductor-folders/conductor-folder.png
# Revert any time with: fileicon rm <dir>

# ---- LOGIN PICTURE -------------------------------------------------------
# System Settings › Users & Groups › click the picture › choose
# conductor-login.png (1024x1024).

echo "Done. Log out/in for highlight + accent to apply everywhere."
