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
  ];
}
