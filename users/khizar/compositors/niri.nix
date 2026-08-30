{ lib, osConfig, hostName, ... }:

{
  config = lib.mkIf osConfig.khizar.desktop.niri.enable {
    xdg.configFile = {
      "niri/config.kdl".source = ../dotfiles/niri/config.kdl;
      "niri/cfg/animation.kdl".source = ../dotfiles/niri/cfg/animation.kdl;
      "niri/cfg/input.kdl".source = ../dotfiles/niri/cfg/input.kdl;
      "niri/cfg/keybinds.kdl".source = ../dotfiles/niri/cfg/keybinds.kdl;
      "niri/cfg/layout.kdl".source = ../dotfiles/niri/cfg/layout.kdl;
      "niri/cfg/misc.kdl".source = ../dotfiles/niri/cfg/misc.kdl;
      "niri/cfg/rules.kdl".source = ../dotfiles/niri/cfg/rules.kdl;

      "niri/cfg/autostart.kdl".source =
        if hostName == "nixos-pc" then
          ../dotfiles/niri/cfg/autostart-pc.kdl
        else
          ../dotfiles/niri/cfg/autostart-laptop.kdl;

      "niri/cfg/display.kdl".source =
        if hostName == "nixos-pc" then
          ../dotfiles/niri/cfg/display-pc.kdl
        else
          ../dotfiles/niri/cfg/display-laptop.kdl;
    };
  };
}
