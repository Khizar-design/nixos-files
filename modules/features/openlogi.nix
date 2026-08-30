{ config, lib, inputs, ... }:

{
  imports = [ inputs.openlogi.nixosModules.default ];

  options.khizar.features.openlogi.enable = lib.mkEnableOption "OpenLogi";

  config = lib.mkIf config.khizar.features.openlogi.enable {
    programs.openlogi.enable = true;
  };
}
