{
  imports = [
    ./hardware-configuration.nix
    ../../modules/features/gaming.nix
  ];

  networking.hostName = "nixos-PC";
}
