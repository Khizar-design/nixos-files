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

    (lib.mkIf cfg.noctalia.enable {
      # Not the whole ~/.config/noctalia dir: ~/.local/state/noctalia/settings.toml
      # is noctalia's own live runtime state (wallpaper path, per-monitor lockscreen
      # widget layout keyed by connector name, ...) and isn't meant to be
      # hand-authored/shared across hosts, so it stays untracked.
      xdg.configFile."noctalia/config.toml".source = ./dotfiles/noctalia/config.toml;
      xdg.configFile."noctalia/palettes".source = ./dotfiles/noctalia/palettes;
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
