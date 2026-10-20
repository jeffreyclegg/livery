# Toolpath · Windows — Rev H · JDC

Shop Floor on Windows 11: dark mode, bearing bronze accent, the Toolpath
Windows Terminal schemes, the mono face and the wallpaper. One WinGet
Configuration file applies all of it.

## Install

Needs winget 1.6 or later (`winget --version`). Run from a normal (not
elevated) PowerShell; winget asks for elevation itself when a package
install needs it.

```powershell
git clone https://github.com/warriorcatlodge/livery $HOME\src\livery
cd $HOME\src\livery\themes\toolpath\windows
winget configure show -f configuration.dsc.yaml   # read what it will do
winget configure -f configuration.dsc.yaml
```

The first run downloads the `PSDscResources` and `Microsoft.WinGet.DSC`
PowerShell modules. Sign out and back in to apply the wallpaper and push the
accent into every app.

Verify:

```powershell
reg query "HKCU\Software\Microsoft\Windows\DWM" /v AccentColor   # 0xff467ace
Test-Path "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\Toolpath\toolpath.json"
```

## What it changes

| Piece | Where | Value |
|---|---|---|
| Windows Terminal, VS Code, JetBrains Mono Nerd Font | winget | installed |
| Dark mode | `HKCU\...\Themes\Personalize` `AppsUseLightTheme`, `SystemUsesLightTheme` | `0` |
| Accent from wallpaper | `HKCU\Control Panel\Desktop` `AutoColorization` | `0` |
| Accent | `HKCU\...\DWM` `AccentColor`, `HKCU\...\Explorer\Accent` `AccentColorMenu` | `0xFF467ACE` (bronze `#CE7A46` as ABGR) |
| Accent on title bars | `HKCU\...\DWM` `ColorPrevalence` | `1` |
| Terminal schemes | `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\Toolpath\toolpath.json` | Toolpath Shop Floor, Toolpath Vellum |
| Wallpaper | `HKCU\Control Panel\Desktop` `WallPaper`, `WallpaperStyle` | `..\wallpapers\toolpath-desktop-shop-floor-16x9.png`, Fill |

The fragment adds schemes only. Pick one in Windows Terminal under Settings >
Profiles > Defaults > Appearance > Color scheme, and set Font face to
`JetBrainsMono Nerd Font` on the same page.

## Schemes

**Toolpath Shop Floor** is slot for slot the Ghostty theme
(`../ghostty/toolpath-shop-floor.ghostty`): normal slots are the Vellum value of each
token, bright slots the Shop Floor value.

**Toolpath Vellum** cannot use that rule. On the stone-tan ground the Shop
Floor halves measure 2.6 to 2.8:1, so the bright slots repeat the normal ones
(the same call Conductor Stainless makes). Slots below 4.5:1 at spec are taken
darker at the same hue until they pass:

| Slot | From | Spec on Vellum | Used | Measures |
|---|---|---|---|---|
| red | bearing bronze `#9C5530` | 4.49 | `#98532F` | 4.66 |
| green | verdigris `#6E9B7A` | 2.54 | `#4B6D54` | 4.66 |
| yellow | temper amber `#E0A036` | 1.82 | `#895D15` | 4.63 |
| cyan | peacock, lightened `#6FAEC0` | 1.98 | `#366C7C` | 4.69 |
| bright black | ink annotation `#6F7680` | 3.68 | `#60666E` | 4.65 |

Cyan deepens from the Shop Floor bright-cyan teal rather than peacock itself:
deepened peacock lands within a few points of dykem and blue and cyan would
read as one color. Cursor stays spec bronze `#9C5530`; it carries no text.

## Wallpapers

From `..`, no new renders. All are 5120 px wide, so every common Windows
resolution is a downscale.

- 16:9 (1080p, 1440p, 4K, 5K): `toolpath-desktop-shop-floor-16x9.png`
- 21:9 ultrawide: `toolpath-desktop-shop-floor-uw.png`
- Vellum: the same names with `vellum`

## Revert

```powershell
$p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
Set-ItemProperty $p AppsUseLightTheme 1
Set-ItemProperty $p SystemUsesLightTheme 1
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\DWM' ColorPrevalence 0
Set-ItemProperty 'HKCU:\Control Panel\Desktop' AutoColorization 1
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\Toolpath" -Recurse
```

Then pick an accent and wallpaper in Settings > Personalization, which
rewrites `AccentColor`, `AccentColorMenu` and `WallPaper`. Packages stay
installed; remove them with `winget uninstall --id <id>` if wanted.
