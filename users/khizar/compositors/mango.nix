{ lib, pkgs, osConfig, ... }:

let
  mangoConfig = ../dotfiles/mango/config.conf;
  mangoAutostart = ../dotfiles/mango/autostart.sh;

  # `mango -c FILE -p` parse-checks a config without starting a compositor, so
  # a typo fails the rebuild instead of the next login. It resolves "./" includes
  # against FILE's directory, hence the staging dir — split config.conf into
  # ./cfg/*.conf later and this keeps working, just copy them in alongside.
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
