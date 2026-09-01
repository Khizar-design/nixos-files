{ lib, ... }:

let
  toggle = description: lib.mkOption {
    type = lib.types.bool;
    default = true;
    inherit description;
  };
in
{
  # Declared on the NixOS side so every switch for a host lives in one place;
  # the Home Manager modules read them through `osConfig`.
  options.khizar.home = {
    zsh.enable           = toggle "zsh with oh-my-zsh and powerlevel10k.";
    theming.enable       = toggle "GTK theme, icon theme, cursor and dconf colour scheme.";
    alacritty.enable     = toggle "Alacritty dotfiles.";
    rofi.enable          = toggle "rofi dotfiles.";
    noctalia.enable      = toggle "noctalia-shell config.toml and custom palettes.";
    mpv.enable           = toggle "mpv, with the ani-skip script.";
    easyeffects.enable   = toggle "EasyEffects audio processing.";
    activitywatch.enable = toggle "ActivityWatch time tracking (aw-server + awatcher).";
  };
}
