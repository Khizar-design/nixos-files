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

    {
      # Was hand-edited at ~/.config/mimeapps.list; managing it here means
      # SUPER,b's `xdg-open http://` (mango keybinds.conf) always resolves to
      # whatever's declared as the browser, instead of a hardcoded binary name.
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/http" = "zen.desktop";
          "x-scheme-handler/https" = "zen.desktop";
          "x-scheme-handler/chrome" = "zen.desktop";
          "text/html" = "zen.desktop";
          "application/x-extension-htm" = "zen.desktop";
          "application/x-extension-html" = "zen.desktop";
          "application/x-extension-shtml" = "zen.desktop";
          "application/xhtml+xml" = "zen.desktop";
          "application/x-extension-xhtml" = "zen.desktop";
          "application/x-extension-xht" = "zen.desktop";
          "x-scheme-handler/discord" = "electron.desktop";
          "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
          "application/vnd.microsoft.portable-executable" = "protonup-qt.desktop";
        };
      };
    }
  ];
}
