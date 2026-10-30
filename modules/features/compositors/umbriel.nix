{ config, inputs, lib, ... }:

let
  cfg = config.khizar.desktop;
in
{
  # Inert until programs.umbriel.enable is set, so importing it is safe on hosts
  # that leave umbriel off.
  imports = [ inputs.umbriel.nixosModules.default ];

  config = lib.mkIf cfg.umbriel.enable {
    # Installs the compositor, its user units and the session file, and sets up
    # xdg-desktop-portal-umbriel with gtk as the fallback portal.
    programs.umbriel.enable = true;

    # start-umbriel, not umbriel: it runs the compositor as umbriel.service, whose
    # BindsTo pulls up graphical-session.target (polkit agent, ActivityWatch, ...).
    # That is what mango needs its own mango-session.target for.
    services.greetd.settings.default_session.command =
      lib.mkIf (cfg.default == "umbriel")
        (lib.mkDefault "${config.programs.umbriel.package}/bin/start-umbriel");
  };
}
