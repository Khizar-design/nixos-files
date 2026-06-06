{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/features/gaming.nix
  ];

  networking.hostName = "nixos-PC";

  fileSystems."/mnt/Games" = {
    device = "/dev/disk/by-uuid/bbbe67d6-2b69-4ae2-a0af-24ef2fb9478e";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" "X-systemd.device-timeout=5s" ];
  };

  fileSystems."/mnt/VMs" = {
    device = "/dev/disk/by-uuid/09d9d042-a3b1-478d-a1ba-685c5fe7525f";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" "X-systemd.device-timeout=5s" ];
  };

  fileSystems."/mnt/Storage" = {
    device = "/dev/disk/by-uuid/dff7c0b3-17a8-48b6-be38-62f5e4b0e3df";
    fsType = "ext4";
    options = [ "defaults" "nofail" "X-systemd.device-timeout=5s" ];
  };

  fileSystems."/mnt/nas" = {
    device = "//100.77.111.96/Public";
    fsType = "cifs";
    options = [
      "credentials=/home/khizar/nixos-files/smb-secrets"
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
