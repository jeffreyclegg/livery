# Conductor for one user: terminal tools, editors, wallpapers and the live
# board. Tools that are not installed yet just find their file waiting.
{ config, lib, ... }:
let
  cfg = config.livery.conductor;
  t = ../themes/conductor;
in
{
  options.livery.conductor = {
    enable = lib.mkEnableOption "the Conductor theme";
    shade = lib.mkOption {
      type = lib.types.enum [
        "moffat"
        "stainless"
      ];
      default = "moffat";
      description = "Ghostty and bat shade. Both are installed either way.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty.settings = {
      theme = "conductor-${cfg.shade}";
      # Ghostty resolves a relative shader path against the config file's
      # directory, so point at the file itself.
      custom-shader = "${t}/ghostty/conductor-dust.glsl";
      custom-shader-animation = true;
      font-family = "DM Mono";
    };

    # Exports XDG_CONFIG_HOME so lazygit and k9s read ~/.config on macOS
    # instead of ~/Library/Application Support.
    xdg.enable = true;
    xdg.configFile = {
      "ghostty/themes/conductor-moffat".source = "${t}/ghostty/conductor-moffat.ghostty";
      "ghostty/themes/conductor-stainless".source = "${t}/ghostty/conductor-stainless.ghostty";
      "starship.toml".source = "${t}/terminal/conductor-starship.toml";
      "eza/theme.yml".source = "${t}/terminal/conductor-eza.yml";
      "lazygit/config.yml".source = "${t}/terminal/conductor-lazygit.yml";
      "btop/themes/conductor.theme".source = "${t}/terminal/conductor-btop.theme";
      "k9s/skins/conductor-moffat.yaml".source = "${t}/terminal/conductor-k9s.yaml";
      "bat/themes/conductor-moffat.tmTheme".source = "${t}/editors/conductor-moffat.tmTheme";
      "bat/themes/conductor-stainless.tmTheme".source = "${t}/editors/conductor-stainless.tmTheme";
      "nvim/colors/conductor.lua".source = "${t}/editors/nvim/colors/conductor.lua";
    };

    # Wallpapers, folder icons and the live board at a stable path:
    # ~/.local/share/livery/conductor.
    xdg.dataFile."livery/conductor".source = t;

    programs.zsh.initContent = "source ${t}/terminal/conductor-fzf.sh";

    # delta's colors only. Turning delta on (programs.delta) sets the pager.
    programs.git.includes = [ { path = "${t}/editors/conductor-delta.gitconfig"; } ];
  };
}
