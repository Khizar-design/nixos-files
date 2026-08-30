{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.system.boot;
in
{
  options.khizar.system.boot = {
    grub.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "GRUB in EFI mode with os-prober.";
    };

    osProber = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Let GRUB scan for other installed operating systems.";
    };

    latestKernel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Track the newest mainline kernel instead of the LTS default.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.grub.enable {
      boot.loader.grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = cfg.osProber;
      };
      boot.loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    })

    (lib.mkIf cfg.latestKernel {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    })
  ];
}
