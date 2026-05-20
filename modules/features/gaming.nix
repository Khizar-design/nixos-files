{ pkgs, ... }:
{
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
}
