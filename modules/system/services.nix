{ config, ... }:
{
  services.upower.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  services.dbus.enable = true;
  services.flatpak.enable = true;
  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';

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

  fileSystems."/mnt/nas" = {
    device = "//100.77.111.96/Public";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-secrets"
      "uid=1000"
      "gid=100"
      "vers=3.0"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
    ];
  };
}
