{ config, lib, ... }:

# programs.openlogi comes from nixpkgs (added upstream Nov 2026). The upstream
# module only installs the package + udev rules, so the agent user service that
# the OpenLogi flake module used to provide is declared here.
{
  options.khizar.features.openlogi.enable = lib.mkEnableOption "OpenLogi";

  config = lib.mkIf config.khizar.features.openlogi.enable {
    programs.openlogi.enable = true;

    systemd.user.services.openlogi-agent = {
      description = "OpenLogi background agent";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = lib.getExe' config.programs.openlogi.package "openlogi-agent";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
