{ config, lib, pkgs, inputs, ... }:

{
  options.khizar.features.winapps.enable =
    lib.mkEnableOption "WinApps (Windows apps from a podman-backed VM)";

  config = lib.mkIf config.khizar.features.winapps.enable {
    # WAFLAVOR=podman needs podman-compose, from khizar.features.podman.
    assertions = [
      {
        assertion = config.khizar.features.podman.enable;
        message = "khizar.features.winapps needs khizar.features.podman.enable = true.";
      }
    ];

    environment.systemPackages = with pkgs; [
      inputs.winapps.packages.${pkgs.system}.winapps
      inputs.winapps.packages.${pkgs.system}.winapps-launcher

      # WinApps runtime dependencies
      freerdp
      dialog
      libnotify
      netcat-openbsd
      curl
      iproute2
    ];
  };
}
