{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.xwayland.enable = true;
  services.libinput.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.niri}/bin/niri-session";
      user = "khizar";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    DISPLAY                               = ":0";
    ELECTRON_OZONE_PLATFORM_HINT          = "auto";
    QT_QPA_PLATFORM                       = "wayland";
    QT_QPA_PLATFORMTHEME                  = "gtk3";
    QT_WAYLAND_DISABLE_WINDOWDECORATION   = "1";
    XDG_CURRENT_DESKTOP                   = "niri";
    XDG_SESSION_TYPE                      = "wayland";
  };

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

  programs.dconf.enable = true;
}
