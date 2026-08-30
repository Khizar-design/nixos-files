{ config, lib, pkgs, ... }:
{
  users.users.khizar = {
    isNormalUser = true;
    description = "Khizar";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
    ]
    # The group only exists when programs.wireshark is enabled.
    ++ lib.optional config.khizar.packages.security.enable "wireshark";
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };
}
