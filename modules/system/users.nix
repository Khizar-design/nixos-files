{ pkgs, ... }:
{
  users.users.khizar = {
    isNormalUser = true;
    description = "Khizar";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.bash;
    packages = with pkgs; [];
  };
}
