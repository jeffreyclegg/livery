# Conductor for VS Code

Two themes: **Conductor Moffat** (dark, default) and **Conductor Stainless** (light).

## Install

Copy the folder (no build step):

```sh
cp -r vscode ~/.vscode/extensions/conductor-theme
```

Or package it and install the .vsix:

```sh
cd vscode
npx @vscode/vsce package --allow-missing-repository
code --install-extension conductor-theme-1.0.0.vsix
```

Reload VS Code, then pick the theme under Preferences: Color Theme.

## Notes

- Sodium: keywords, the cursor, primary buttons, the active tab rule. Warbonnet: errors and deletions only.
  Brunswick: additions and passing tests only. Hudson: types and structure. Dusk: constants only.
- The faintest ink tier is used for comments only.
- The status bar is the departure board: dark flap leaves with sodium figures in both shades.
- Strings use **lunar**, a derived color (Moffat `#7FC4CC`, the ghostty cyan; Stainless `#1F5F66`).
- Terminal ANSI colors in Moffat match `conductor-moffat.ghostty` exactly.
