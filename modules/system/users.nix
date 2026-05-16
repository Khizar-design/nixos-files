{ pkgs, ... }:
{
  users.users.khizar = {
    isNormalUser = true;
    description = "Khizar";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };
}
