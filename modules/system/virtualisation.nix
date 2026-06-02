{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;   # lets you run `docker` commands via Podman
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
