{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.hardware;
in
{
  options.khizar.hardware = {
    amdgpu.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "AMD graphics stack (amdgpu driver, 32-bit GL, ROCm ICD).";
    };

    bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Bluetooth support. Note that services.blueferry turns this on
        regardless — options merge, so any `true` wins.
      '';
    };

    xboxController.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        xpadneo — correct button mapping, rumble and battery reporting for the
        Xbox Elite controller over Bluetooth, which the stock xpad driver lacks.
      '';
    };

    uinput.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "/dev/uinput, for virtual input devices (Sunshine, ydotool, ...).";
    };

    rembrandtDmcubPin.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Pin amdgpu/yellow_carp_dmcub.bin (Rembrandt iGPU display firmware) to
        linux-firmware 20260810. The 20260910 blob (0x0400004A) is rejected by
        the PSP ("failed to load ucode DMCUB"), which floods dmesg with DMCUB
        errors and makes backlight changes lag. Drop once upstream ships a
        working blob.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.amdgpu.enable {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ rocmPackages.clr.icd ];
      };
      services.xserver.videoDrivers = [ "amdgpu" ];
    })

    (lib.mkIf cfg.bluetooth.enable { hardware.bluetooth.enable = true; })
    (lib.mkIf cfg.xboxController.enable { hardware.xpadneo.enable = true; })
    (lib.mkIf cfg.uinput.enable { hardware.uinput.enable = true; })

    (lib.mkIf cfg.rembrandtDmcubPin.enable {
      # hiPrio wins the collision with linux-firmware's copy in the firmware buildEnv.
      hardware.firmware = [
        (lib.hiPrio (pkgs.runCommand "yellow-carp-dmcub-20260810" {
          src = pkgs.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/amdgpu/yellow_carp_dmcub.bin?h=20260810";
            name = "yellow_carp_dmcub.bin";
            hash = "sha256-S8uR1YunJ2hIRbAqnN0y83y1qfcb1Lk9TmeAlEZc2kc=";
          };
        } ''
          install -Dm644 $src $out/lib/firmware/amdgpu/yellow_carp_dmcub.bin
        ''))
      ];
    })
  ];
}
