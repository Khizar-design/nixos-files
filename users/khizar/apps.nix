{ lib, pkgs, osConfig, ... }:

let
  cfg = osConfig.khizar.home;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.alacritty.enable {
      xdg.configFile."alacritty".source = ./dotfiles/alacritty;
    })

    (lib.mkIf cfg.rofi.enable {
      xdg.configFile."rofi".source = ./dotfiles/rofi;
    })

    (lib.mkIf cfg.mpv.enable {
      programs.mpv.enable = true;
      xdg.configFile."mpv/scripts/skip.lua".source =
        "${pkgs.ani-skip}/share/mpv/scripts/skip.lua";
    })

    (lib.mkIf cfg.easyeffects.enable {
      services.easyeffects.enable = true;
    })
  ];
}
