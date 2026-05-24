{ pkgs, ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Resume device for hibernate — swap partition UUID
  boot.resumeDevice = "/dev/disk/by-uuid/0b01cb0b-40e4-4ce1-a771-4094cffcc4ac";
}
