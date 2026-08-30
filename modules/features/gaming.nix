{ config, lib, pkgs, ... }:

{
  options.khizar.features.gaming.enable =
    lib.mkEnableOption "Steam, gamemode and the usual launcher stack";

  config = lib.mkIf config.khizar.features.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
    };

    programs.gamemode.enable = true;
    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs; [
      heroic
      mangohud
      protonup-qt
    ];
  };
}
