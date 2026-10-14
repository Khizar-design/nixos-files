{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.desktop;
in
{
  config = lib.mkIf cfg.niri.enable {
    programs.niri.enable = true;

    xdg.portal.config.niri = {
      default = lib.mkForce [ "wlr" "gtk" ];
      "org.freedesktop.impl.portal.Camera" = [ "gtk" ];
    };

    # No xwayland-satellite unit and no global DISPLAY: niri (>= 25.08) creates
    # the X11 socket itself, sets DISPLAY for everything it spawns, and starts
    # xwayland-satellite (from PATH, see packages.nix) on the first X11 client.
    # A separate unit pinned to :0 raced niri for that socket: whichever lost
    # either restart-looped or pushed niri onto :1, splitting apps between two
    # X servers. niri also strips an inherited DISPLAY at startup, so the old
    # sessionVariables entry never reached its children anyway.

    services.greetd.settings.default_session.command =
      lib.mkIf (cfg.default == "niri") (lib.mkDefault "${pkgs.niri}/bin/niri-session");
  };
}
