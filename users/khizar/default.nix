{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
  ];
  home.username = "khizar";
  home.homeDirectory = "/home/khizar";
  home.stateVersion = "25.11";
}
