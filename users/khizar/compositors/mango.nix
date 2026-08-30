{ lib, pkgs, osConfig, ... }:

let
  mangoConfig = ../dotfiles/mango/config.conf;
  mangoAutostart = ../dotfiles/mango/autostart.sh;

  # `mango -c FILE -p` parse-checks a config without starting a compositor, but
  # it resolves "./" includes against FILE's directory, so hand it the whole
  # tree rather than the bare config file.
  checkedConfig = pkgs.runCommand "mango-config.conf" { env.HOME = "/build/home"; } ''
    mkdir -p tree
    cp ${mangoConfig} tree/config.conf
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
    };

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
