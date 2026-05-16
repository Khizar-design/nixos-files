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
    ./gaming.nix
    ./virtualisation.nix
  ];
}
