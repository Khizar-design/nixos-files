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

    # xwayland-satellite owns :0, and everything launched under niri has to know
    # where to find it. mango has XWayland built in and is wrapped so it never
    # sees this — see mango.nix.
    environment.sessionVariables.DISPLAY = ":0";

    systemd.user.services.xwayland-satellite = {
      description = "Xwayland outside the Wayland sandbox";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
        Restart = "on-failure";
      };
    };

    services.greetd.settings.default_session.command =
      lib.mkIf (cfg.default == "niri") (lib.mkDefault "${pkgs.niri}/bin/niri-session");
  };
}
