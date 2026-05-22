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

  fileSystems."/mnt/nas" = {
    device = "//100.77.111.96/Public";
    fsType = "cifs";
    options = [
      "credentials=/home/khizar/nixos/smb-secrets"
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
