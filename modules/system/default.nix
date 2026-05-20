{ config, pkgs, inputs, ... }:
{
  imports = [
    ./boot.nix
    ./core.nix
    ./hardware.nix
    ./desktop.nix
    ./services.nix
    ./packages.nix
    ./users.nix
./virtualisation.nix
  ];
}
