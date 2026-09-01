{ config, lib, pkgs, ... }:

let
  cfg = config.khizar.desktop;
in
{
  imports = [
    ./niri.nix
    ./mango.nix
  ];

  options.khizar.desktop = {
    niri.enable = lib.mkEnableOption "the niri compositor session";
    mango.enable = lib.mkEnableOption "the mango compositor session";

    default = lib.mkOption {
      type = lib.types.enum [ "niri" "mango" ];
      default = if cfg.niri.enable then "niri" else "mango";
      defaultText = lib.literalMD "whichever compositor is enabled; `niri` if both are";
      description = ''
        Compositor greetd starts for the autologin session, and the entry
        noctalia-greeter preselects in its picker.

        Only worth setting by hand when both compositors are enabled and you
        want the other one; with a single compositor enabled this follows it.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.niri.enable || cfg.mango.enable;
        message = "khizar.desktop: enable at least one compositor.";
      }
      {
        assertion = cfg.${cfg.default}.enable;
        message = ''
          khizar.desktop.default is "${cfg.default}" but
          khizar.desktop.${cfg.default}.enable is false.
        '';
      }
    ];

    services.greetd.enable = true;
    services.libinput.enable = true;
    programs.xwayland.enable = true;
    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    };

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      # The de facto NixOS convention: most nixpkgs-packaged Electron apps
      # (equibop, discord, teams-for-linux, slack, ...) wrap their binary with
      # a check for exactly this var — when set, they switch on native
      # Wayland (ozone-platform) instead of falling back to XWayland, which is
      # also what makes their WebRTC screen-share use a live PipeWire stream
      # instead of a single static frame grabbed through X11. Applies to any
      # future Electron app installed from nixpkgs too, no per-package wrapper
      # needed.
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      XDG_SESSION_TYPE = "wayland";
      # Both compositors setenv this for themselves; it is here for anything
      # that reads it before the compositor starts.
      XDG_CURRENT_DESKTOP = cfg.default;
    };

    # Neither niri nor mango ships a polkit agent, so authorization prompts fall
    # back to the tty agent — invisible to anything launched from a launcher.
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "Graphical polkit authentication agent";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
    };
  };
}
