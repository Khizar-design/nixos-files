{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./activitywatch.nix
  ];
  home.username = "khizar";
  home.homeDirectory = "/home/khizar";
  home.stateVersion = "25.11";
}
