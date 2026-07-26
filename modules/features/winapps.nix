{ pkgs, inputs, ... }:
{
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

  # Podman backend for the WinApps Windows VM (WAFLAVOR=podman) needs
  # podman-compose, already enabled system-wide in virtualisation.nix.
}
