{ ... }:
{
  imports = [
    ./boot.nix
    ./core.nix
    ./hardware.nix
    ./services.nix
    ./packages.nix
    ./users.nix
    ./virtualisation.nix

    ../features
  ];
}
