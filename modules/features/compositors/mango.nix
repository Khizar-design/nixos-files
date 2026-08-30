{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.desktop;

  # mango is wlroots-based and wlr_backend_autocreate picks its backend by
  # sniffing the environment. niri.nix sets DISPLAY=":0" system-wide for
  # xwayland-satellite, and pam_env hands it to every session — so mango would
  # see DISPLAY, choose the X11 backend, find no X server and exit. Strip it and
  # pin the backend, the same fix noctalia-greeter needs.
  #
  # This wraps both the login entry and the `mango-session` command, so it holds
  # whether the session comes from greetd or from the greeter's picker. Running
  # bare `mango` from a tty is unaffected.
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

    xdg.portal = {
      configPackages = [ pkgs.mango ];
      config.mango = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        # wlr has no Inhibit implementation
        "org.freedesktop.impl.portal.Inhibit" = [ "gtk" ];
      };
    };

    services.greetd.settings.default_session.command =
      lib.mkIf (cfg.default == "mango") (lib.mkDefault "${mango-session}/bin/mango-session");
  };
}
