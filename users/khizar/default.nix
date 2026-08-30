{ ... }:

{
  imports = [
    ./shell.nix
    ./theming.nix
    ./apps.nix
    ./activitywatch.nix
    ./compositors
  ];

  home.username = "khizar";
  home.homeDirectory = "/home/khizar";
  home.stateVersion = "25.11";
}
