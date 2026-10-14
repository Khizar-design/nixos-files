{ lib, pkgs, osConfig, hostName, ... }:

let
  isPC = hostName == "nixos-pc";

  niriConfig = ../dotfiles/niri/config.kdl;

  # Every ./cfg/*.kdl config.kdl includes, with the per-host picks folded in.
  fragments = {
    "animation.kdl" = ../dotfiles/niri/cfg/animation.kdl;
    "input.kdl" = ../dotfiles/niri/cfg/input.kdl;
    "keybinds.kdl" = ../dotfiles/niri/cfg/keybinds.kdl;
    "layout.kdl" = ../dotfiles/niri/cfg/layout.kdl;
    "misc.kdl" = ../dotfiles/niri/cfg/misc.kdl;
    "rules.kdl" = ../dotfiles/niri/cfg/rules.kdl;
  } // {
    "autostart.kdl" =
      if isPC then
        ../dotfiles/niri/cfg/autostart-pc.kdl
      else
        ../dotfiles/niri/cfg/autostart-laptop.kdl;

    "display.kdl" =
      if isPC then
        ../dotfiles/niri/cfg/display-pc.kdl
      else
        ../dotfiles/niri/cfg/display-laptop.kdl;
  };

  # Started from cfg/autostart-*.kdl; see the header of zen-placer.sh.
  zenPlacer = pkgs.writeShellApplication {
    name = "niri-zen-placer";
    runtimeInputs = [ pkgs.jq osConfig.programs.niri.package ];
    text = builtins.readFile ../dotfiles/niri/zen-placer.sh;
  };

  # Same idea as mango's checkedConfig: `niri validate` the whole include tree
  # so a typo or a removed option fails the rebuild instead of the next login
  # (niri would otherwise start on its built-in default config).
  checkedConfig = pkgs.runCommand "niri-config.kdl" { env.HOME = "/build/home"; } ''
    mkdir -p tree/cfg
    cp ${niriConfig} tree/config.kdl
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: "cp ${src} tree/cfg/${name}") fragments
    )}
    ${lib.getExe osConfig.programs.niri.package} validate -c "$PWD/tree/config.kdl"
    cp tree/config.kdl $out
  '';
in
{
  config = lib.mkIf osConfig.khizar.desktop.niri.enable {
    home.packages = [ zenPlacer ];

    xdg.configFile = {
      "niri/config.kdl".source = checkedConfig;
    } // lib.mapAttrs' (name: src: lib.nameValuePair "niri/cfg/${name}" { source = src; }) fragments;
  };
}
