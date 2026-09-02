{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.desktop;

  mangoPortalConfig = {
    default = [ "gtk" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    "org.freedesktop.impl.portal.Inhibit" = [ "gtk" ];
  };

  mango-session = pkgs.runCommand "mango-session"
    {
      passthru.providedSessions = [ "mango" ];
    }
    ''
      mkdir -p $out/bin $out/share/wayland-sessions

      cat > $out/bin/mango-session <<EOF
      #!${pkgs.runtimeShell}
      exec ${pkgs.coreutils}/bin/env -u DISPLAY WLR_BACKENDS=drm,libinput \
        ${lib.getExe pkgs.mango} "\$@"
      EOF
      chmod +x $out/bin/mango-session

      substitute ${pkgs.mango}/share/wayland-sessions/mango.desktop \
        $out/share/wayland-sessions/mango.desktop \
        --replace-fail "Exec=mango" "Exec=$out/bin/mango-session"
    '';
in
{
  config = lib.mkIf cfg.mango.enable {
    environment.systemPackages = [
      pkgs.mango # mango + mmsg
      mango-session
    ];

    services.displayManager.sessionPackages = [ mango-session ];

    # niri's module turns this on too; set it here so a mango-only host still
    # gets the shared desktop plumbing (XDG_DATA_DIRS, .desktop handling, ...).
    services.graphical-desktop.enable = lib.mkDefault true;

    xdg.portal = {
      configPackages = [ pkgs.mango ];
      # noctalia-shell is started with XDG_CURRENT_DESKTOP=wlroots (see
      # dotfiles/mango/autostart-*.sh), so it needs the same portal routing
      # under that name or its pickers and screencasts fall back to defaults.
      config.mango = mangoPortalConfig;
      config.wlroots = mangoPortalConfig;
    };

    services.greetd.settings.default_session.command =
      lib.mkIf (cfg.default == "mango") (lib.mkDefault "${mango-session}/bin/mango-session");
  };
}
