{inputs, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/features/laptop.nix
    
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
  ];

  networking.hostName = "nixos-laptop";

  fileSystems."/mnt/Lexar" = {
    device = "/dev/disk/by-uuid/14237b4d-f67f-4f56-b4ce-8a3b7ef88c6a";
    fsType = "ext4";
    options = [ "defaults" "nofail" "X-systemd.device-timeout=5s" ];
  };
}
