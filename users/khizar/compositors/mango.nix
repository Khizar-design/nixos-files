{ lib, pkgs, osConfig, hostName, ... }:

let
  isPC = hostName == "nixos-pc";

  mangoConfig = ../dotfiles/mango/config.conf;

  mangoAutostart =
    if isPC then
      ../dotfiles/mango/autostart-pc.sh
    else
      ../dotfiles/mango/autostart-laptop.sh;

  monitorConfig =
    if isPC then
      ../dotfiles/mango/cfg/monitor-pc.conf
    else
      ../dotfiles/mango/cfg/monitor-laptop.conf;

  # Host-independent fragments, sourced by config.conf.
  fragments = {
    "animation.conf" = ../dotfiles/mango/cfg/animation.conf;
    "appearance.conf" = ../dotfiles/mango/cfg/appearance.conf;
    "input.conf" = ../dotfiles/mango/cfg/input.conf;
    "keybinds.conf" = ../dotfiles/mango/cfg/keybinds.conf;
    "layout.conf" = ../dotfiles/mango/cfg/layout.conf;
    "rules.conf" = ../dotfiles/mango/cfg/rules.conf;
  } // { "monitor.conf" = monitorConfig; };

  # `mango -c FILE -p` parse-checks a config without starting a compositor, so
  # a typo fails the rebuild instead of the next login. It resolves "./" includes
  # against FILE's directory, hence the staging dir — every ./cfg/*.conf the
  # config sources must be copied in alongside or it is silently skipped
  # (a missing include only warns; it does not fail the parse).
  checkedConfig = pkgs.runCommand "mango-config.conf" { env.HOME = "/build/home"; } ''
    mkdir -p tree/cfg
    cp ${mangoConfig} tree/config.conf
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: "cp ${src} tree/cfg/${name}") fragments
    )}
    ${lib.getExe pkgs.mango} -c "$PWD/tree/config.conf" -p
    cp tree/config.conf $out
  '';
in
{
  config = lib.mkIf osConfig.khizar.desktop.mango.enable {
    xdg.configFile = {
      "mango/config.conf".source = checkedConfig;
      "mango/autostart.sh" = {
        source = mangoAutostart;
        executable = true;
      };
    } // lib.mapAttrs' (name: src: lib.nameValuePair "mango/cfg/${name}" { source = src; }) fragments;

    # mango has no session wrapper of its own, so autostart.sh starts this and
    # BindsTo drags graphical-session.target (polkit agent, ...) up with it.
    systemd.user.targets.mango-session = {
      Unit = {
        Description = "mango compositor session";
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
