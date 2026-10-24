# Toolpath for a Mac without home-manager: the theme folder lands at
# /etc/livery/toolpath, a fixed path that dotfiles managed elsewhere (chezmoi
# on scriptshade) point at. Livery owns the assets; the dotfiles own only
# which file each tool reads.
{ config, lib, ... }:
{
  options.livery.toolpath.enable = lib.mkEnableOption "the Toolpath theme files at /etc/livery/toolpath";

  config = lib.mkIf config.livery.toolpath.enable {
    environment.etc."livery/toolpath".source = ../themes/toolpath;
  };
}
