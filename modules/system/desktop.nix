{ pkgs, ... }:
{
  programs.niri.enable = true;
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
    ELECTRON_OZONE_PLATFORM_HINT          = "auto";
    QT_QPA_PLATFORM                       = "wayland";
    QT_QPA_PLATFORMTHEME                  = "gtk3";
    QT_WAYLAND_DISABLE_WINDOWDECORATION   = "1";
    XDG_CURRENT_DESKTOP                   = "niri";
    XDG_SESSION_TYPE                      = "wayland";
  };

  programs.dconf.enable = true;
}
