# Conductor for the whole Mac: dark mode, Sodium highlight, fonts, and
# optionally Plash for the live wallpaper.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.livery.conductor;
in
{
  options.livery.conductor = {
    enable = lib.mkEnableOption "Conductor's system settings";
    plash = lib.mkEnableOption ''
      Plash from the App Store, which shows the live dust board as the
      desktop. Needs nix-darwin's homebrew module and an App Store sign-in'';
  };

  config = lib.mkIf cfg.enable {
    # Sodium #F2A33C as the selection highlight (macOS takes a custom value
    # even though Settings only shows presets), Orange as the nearest accent
    # preset. Needs a log-out to reach every app.
    system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
    system.defaults.CustomUserPreferences.NSGlobalDomain = {
      AppleHighlightColor = "0.949 0.639 0.235 Other";
      AppleAccentColor = 1;
    };

    # DM Mono for terminals, Jost and Big Shoulders for pages and docs.
    # Names are file prefixes in google/fonts.
    fonts.packages = [
      (pkgs.google-fonts.override {
        fonts = [
          "DMMono"
          "Jost"
          "BigShoulders"
        ];
      })
    ];

    homebrew.masApps = lib.mkIf cfg.plash { Plash = 1494023538; };
  };
}
