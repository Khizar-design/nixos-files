{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../hosts/nixos-laptop/hardware-configuration.nix
    ./boot.nix
    ./core.nix
    ./hardware.nix
    ./desktop.nix
    ./services.nix
    ./packages.nix
    ./users.nix
    ./gaming.nix
    ./virtualisation.nix
  ];
}
