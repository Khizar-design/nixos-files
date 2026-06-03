{ config, ... }:
{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";  # must bind to all interfaces so Podman containers can reach it
    # acceleration = "cuda";  # uncomment if you have an NVIDIA GPU
    # acceleration = "rocm";  # uncomment if you have an AMD GPU
  };
  services.upower.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
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

  services.syncthing = {
    enable = true;
    user = "khizar";
    dataDir = "/home/khizar";
    openDefaultPorts = true;
  };

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

  systemd.services.odysseus = {
    description = "Odysseus AI Workspace (podman-compose)";
    after    = [ "network-online.target" "podman.service" ];
    wants    = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type             = "oneshot";
      RemainAfterExit  = true;
      User             = "khizar";
      WorkingDirectory = "/home/khizar/odysseus";
      ExecStart        = "/run/current-system/sw/bin/podman-compose up -d";
      ExecStop         = "/run/current-system/sw/bin/podman-compose down";
    };
  };

}
