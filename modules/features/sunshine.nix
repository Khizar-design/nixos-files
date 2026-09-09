{ config, lib, ... }:

{
  options.khizar.features.sunshine.enable =
    lib.mkEnableOption "Sunshine game/desktop streaming host";

  config = lib.mkIf config.khizar.features.sunshine.enable {
    services.sunshine = {
      enable      = true;
      autoStart   = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    # No WAYLAND_DISPLAY here on purpose. autostart-laptop.sh runs
    # `systemctl --user import-environment WAYLAND_DISPLAY ...`, and a unit's own
    # Environment= overrides that imported value. Hardcoding it to the wrong socket
    # made Sunshine fall back to KMS capture, which ignores output_name and grabs
    # the first connector (eDP-1) — the iPad got a duplicate of the laptop panel
    # instead of the HDMI-A-1 dummy output. Letting it inherit keeps it correct even
    # if the socket number changes.
    systemd.user.services.sunshine.environment = {
      XDG_RUNTIME_DIR = "/run/user/1000";
      PULSE_SERVER    = "unix:/run/user/1000/pulse/native";
    };
  };
}
