{ lib, pkgs, osConfig, hostName, ... }:

let
  isPC = hostName == "nixos-pc";

  umbriel = osConfig.programs.umbriel.package;

  umbrielConfig = ../dotfiles/umbriel/config.toml;

  # The hosts split here on purpose: *-pc.toml is ported from the mango config the
  # PC runs, *-laptop.toml from the niri config the laptop runs. Only appearance
  # was the same in both.
  perHost = name:
    ../dotfiles/umbriel/cfg + "/${name}-${if isPC then "pc" else "laptop"}.toml";

  # Every cfg/*.toml config.toml includes.
  fragments = {
    "appearance.toml" = ../dotfiles/umbriel/cfg/appearance.toml;
  } // lib.genAttrs' [ "animation" "autostart" "input" "keybinds" "layout" "monitor" "rules" ]
    (name: lib.nameValuePair "${name}.toml" (perHost name));

  # Started from cfg/autostart-*.toml; see the header of zen-placer.sh.
  zenPlacer = pkgs.writeShellApplication {
    name = "umbriel-zen-placer";
    runtimeInputs = [ pkgs.jq umbriel ];
    text = builtins.readFile ../dotfiles/umbriel/zen-placer.sh;
  };

  # Bound to Mod+C in cfg/keybinds-pc.toml; see the header of zoom.sh.
  zoom = pkgs.writeShellApplication {
    name = "umbriel-zoom";
    runtimeInputs = [ pkgs.jq umbriel ];
    text = builtins.readFile ../dotfiles/umbriel/zoom.sh;
  };

  # Bound to CTRL+Shift+1/2/3 in keybinds-laptop.toml; see the header of screenshot.sh.
  screenshot = pkgs.writeShellApplication {
    name = "umbriel-screenshot";
    runtimeInputs = [ pkgs.coreutils pkgs.grim pkgs.jq pkgs.slurp pkgs.wl-clipboard umbriel ];
    text = builtins.readFile ../dotfiles/umbriel/screenshot.sh;
  };

  # Same idea as mango's checkedConfig, and more important here: on any startup
  # error umbriel drops to its packaged config, whose binds launch kitty and leave
  # no way to reach the rest of this setup. `config validate` also fails on
  # warnings, so an unknown key or action fails the rebuild, not the next login.
  checkedConfig = pkgs.runCommand "umbriel-config.toml" { env.HOME = "/build/home"; } ''
    mkdir -p tree/cfg
    cp ${umbrielConfig} tree/config.toml
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: "cp ${src} tree/cfg/${name}") fragments
    )}
    ${lib.getExe umbriel} config validate -c "$PWD/tree/config.toml"
    cp tree/config.toml $out
  '';
in
{
  config = lib.mkIf osConfig.khizar.desktop.umbriel.enable {
    home.packages = [ screenshot zenPlacer zoom ];

    # Per-file links rather than the whole directory, so ~/.config/umbriel stays
    # writable for the noctalia.toml that noctalia's colour template generates.
    xdg.configFile = {
      "umbriel/config.toml".source = checkedConfig;
    } // lib.mapAttrs' (name: src: lib.nameValuePair "umbriel/cfg/${name}" { source = src; }) fragments;
  };
}
