{ config, lib, ... }:

let
  cfg = config.khizar.system;
in
{
  options.khizar.system = {
    networkmanager.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "NetworkManager, with the wpa_supplicant backend.";
    };

    waitOnline = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Keep NetworkManager-wait-online.service. Off by default — it stalls boot
        for up to 30s on a machine that is fine coming up offline.
      '';
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Edmonton";
      description = "System time zone.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_CA.UTF-8";
      description = "Default locale.";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Console / X keyboard layout.";
    };

    nixGc.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Weekly nix-collect-garbage of generations older than 7 days.";
    };
  };

  config = lib.mkMerge [
    {
      time.timeZone = cfg.timeZone;
      i18n.defaultLocale = cfg.locale;

      services.xserver.xkb = {
        layout = cfg.keyboardLayout;
        variant = "";
      };

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };

      system.stateVersion = "25.11";
    }

    (lib.mkIf cfg.networkmanager.enable {
      networking.wireless.enable = true;
      networking.networkmanager.enable = true;
    })

    (lib.mkIf (!cfg.waitOnline) {
      systemd.services.NetworkManager-wait-online.enable = false;
    })

    (lib.mkIf cfg.nixGc.enable {
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    })
  ];
}
