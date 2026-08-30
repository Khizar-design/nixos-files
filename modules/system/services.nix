{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.services;
in
{
  options.khizar.services = {
    audio.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "PipeWire (ALSA + 32-bit + PulseAudio bridge + WirePlumber).";
    };

    ollama = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Local Ollama model server.";
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = ''
          Bind address. Defaults to all interfaces so Podman containers can
          reach it; set to "127.0.0.1" to keep it host-local.
        '';
      };
      acceleration = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "cuda" "rocm" ]);
        default = null;
        description = "GPU acceleration backend, or null for CPU.";
      };
    };

    flatpak.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Flatpak support.";
    };

    tailscale.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Tailscale, plus firewall trust for tailscale0.";
    };

    syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Syncthing running as khizar over /home/khizar.";
    };

    kdeconnect.openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the KDE Connect / GSConnect port range (1714-1764).";
    };

    upower.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "UPower — battery and power-device reporting for the shell.";
    };

    autoNegotiateEthernet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "udev rule forcing autoneg on for wired interfaces.";
    };
  };

  config = lib.mkMerge [
    {
      services.dbus.enable = true;

      networking.firewall.enable = true;

      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
      '';
    }

    (lib.mkIf cfg.audio.enable {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      services.pulseaudio.enable = false;
    })

    (lib.mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        inherit (cfg.ollama) host;
      } // lib.optionalAttrs (cfg.ollama.acceleration != null) {
        inherit (cfg.ollama) acceleration;
      };
    })

    (lib.mkIf cfg.upower.enable { services.upower.enable = true; })
    (lib.mkIf cfg.flatpak.enable { services.flatpak.enable = true; })

    (lib.mkIf cfg.tailscale.enable {
      services.tailscale.enable = true;
      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
    })

    (lib.mkIf cfg.syncthing.enable {
      services.syncthing = {
        enable = true;
        user = "khizar";
        dataDir = "/home/khizar";
        openDefaultPorts = true;
      };
    })

    (lib.mkIf cfg.kdeconnect.openFirewall {
      networking.firewall = {
        allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
        allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
      };
    })

    (lib.mkIf cfg.autoNegotiateEthernet {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", KERNEL=="en*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k autoneg on"
        ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k autoneg on"
      '';
    })
  ];
}
