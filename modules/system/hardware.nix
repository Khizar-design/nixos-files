{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.bluetooth.enable = true;

  # Xbox Elite controller over Bluetooth: correct button mapping, rumble,
  # and battery reporting (stock kernel xpad driver lacks these over BT).
  hardware.xpadneo.enable = true;

  hardware.uinput.enable = true;
}
