# livery

Jeff's themes and the platform customizations that install them. The
artifact side (CSS tokens, specimen pages, the theming skill) stays in
`warriorcatlodge/skills`; this repo holds everything that lands on a machine.

| Theme | Mac (nix) | Windows | Omarchy | Wallpapers |
|---|---|---|---|---|
| Conductor | `homeManagerModules.conductor`, `darwinModules.conductor` | | | PNG, Dynamic Desktop HEIC, live board |
| Toolpath | `themes/toolpath/macos` (scripts) | `themes/toolpath/windows` | `themes/toolpath/omarchy` | PNG, Dynamic Desktop HEIC |

## Mac, with nix-darwin and home-manager

```nix
inputs.livery.url = "github:warriorcatlodge/livery";
```

```nix
modules = [
  inputs.livery.darwinModules.conductor
  { livery.conductor.enable = true; }
];
home-manager.users.jeff = {
  imports = [ inputs.livery.homeManagerModules.conductor ];
  livery.conductor.enable = true;
};
```

Home-manager options: `livery.conductor.shade` picks `moffat` (default) or
`stainless` for Ghostty and the JankyBorders window border
(`~/.config/borders/bordersrc`). The theme folder lands at
`~/.local/share/livery/conductor`.

nix-darwin options: `livery.conductor.plash = true` installs Plash from the
App Store (needs nix-darwin's homebrew module and an App Store sign-in).

### Wallpaper

macOS has no setting nix can write for the wallpaper, so set it once:

```sh
osascript -e 'tell app "System Events" to set picture of every desktop to POSIX file "'"$HOME"'/.local/share/livery/conductor/wallpapers/conductor-dynamic.heic"'
```

The `conductor-dynamic*.heic` files hold Stainless and Moffat. Set to
Dynamic, macOS shows Stainless 07:00 to 19:00 and Moffat otherwise; set to
Automatic, it follows Light/Dark mode. `-16x9` suits 5K and Studio Display,
`-uw` ultrawide. Rebuild them with `tools/dynamic-desktop.py`.

### Live board

With Plash installed, point it at the board once:

```sh
open "plash:add?url=file://$HOME/.local/share/livery/conductor/live/board.html"
```

It follows Light/Dark mode and pauses when the desktop is hidden.

### AeroSpace window borders

AeroSpace has no colors of its own; the theme reaches it through
[JankyBorders](https://github.com/FelixKratz/JankyBorders), which outlines the
focused window. Each shade has a `bordersrc` under `themes/*/borders/`:
active is the theme's action color, inactive its strong line. Install one as
`~/.config/borders/bordersrc` (executable) and start `borders` from AeroSpace:

```toml
after-startup-command = ['exec-and-forget borders']
```

## Windows

See `themes/toolpath/windows/README.md` (`winget configure`).

## Omarchy

```sh
cp -r themes/toolpath/omarchy ~/.config/omarchy/themes/toolpath
omarchy-theme-set toolpath
```
