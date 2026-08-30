{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.features.podman;
in
{
  options.khizar.features.podman = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Podman with podman-compose.";
    };

    dockerCompat = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Provide a `docker` command backed by Podman.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      inherit (cfg) dockerCompat;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = [ pkgs.podman-compose ];
  };
}
