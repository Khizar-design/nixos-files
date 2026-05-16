{ config, ... }:
{
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT       = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC        = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT     = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_AC      = "performance";
      CPU_BOOST_ON_BAT                  = 0;
      CPU_BOOST_ON_AC                   = 1;
      RUNTIME_PM_ON_BAT                 = "auto";
      RUNTIME_PM_ON_AC                  = "on";
      USB_AUTOSUSPEND                   = 1;
      WOL_DISABLE                       = "Y";
    };
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # TLP conflicts with power-profiles-daemon
  services.power-profiles-daemon.enable = false;

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
    ACTION=="add|change", ATTRS{name}=="ELAN901C:00 04F3:2EDE", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

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
