{ ... }:
{
  services.sunshine = {
    enable      = true;
    autoStart   = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  systemd.user.services.sunshine.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
    PULSE_SERVER    = "unix:/run/user/1000/pulse/native";
    WAYLAND_DISPLAY = "wayland-1";
  };
}
