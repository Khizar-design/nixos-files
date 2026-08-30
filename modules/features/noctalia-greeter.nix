{ config, inputs, lib, pkgs, ... }:
let
  # The greeter runs as the unprivileged `greeter` user and /home/khizar is 0700,
  # so it cannot read anything under the home directory. Wallpapers therefore live
  # in the repo: the flake copies them into /nix/store, which is world-readable and
  # GC-rooted by the system generation. Both images are tracked in ./greeter/ —
  # swap this one line to change the login wallpaper.
  wallpaper = ./greeter/nerv-central-dogma.png; # or ./greeter/anonymous.png
in
{
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  programs.noctalia-greeter = {
    enable = true;

    # Full declarative greeter.toml (overwritten on each activation).
    # See examples/greeter.toml upstream for every key.
    settings = {
      # Picker label from `noctalia-greeter sessions`, not the .desktop id.
      session.default = "Niri";
      # Skip the user list and open the password step directly.
      user.default = "khizar";

      appearance = {
        # "Synced" means "use the palette below" rather than a builtin scheme.
        scheme = "Synced";
        theme_mode = "dark";
        font_family = "Libre Baskerville";
        # Password mask: "default" (filled circles) or "random" (cycled glyphs).
        password_style = "random";
        hide_logo = true;
        corner_radius_scale = 1.0;

        # Lifted from ~/.config/noctalia/colors.json (Lilac AMOLED, dark) so the
        # login screen and the desktop are visibly the same theme.
        palette = {
          primary            = "#b58fff";
          on_primary         = "#000000";
          secondary          = "#c79aff";
          on_secondary       = "#000000";
          tertiary           = "#d8b4ff";
          on_tertiary        = "#000000";
          error              = "#ff6f9b";
          on_error           = "#000000";
          surface            = "#000000";
          on_surface         = "#e8d8ff";
          surface_variant    = "#110d1a";
          on_surface_variant = "#b58fff";
          outline            = "#4c3a70";
          shadow             = "#000000";
          hover              = "#9bfece";
          on_hover           = "#0e0e43";
        };

        wallpaper = {
          # Interpolating the path literal copies the image into the store and
          # yields its absolute store path, which is what the greeter needs.
          path = "${wallpaper}";
          # Both images are exactly 1920x1200 — eDP-1's native mode — so crop and
          # fit are equivalent here. fill_color only shows if that stops being true.
          fill_mode = "crop";
          fill_color = "#000000";
        };
      };

      # Blank the outputs after 5 min at the login screen, matching the shell's
      # screenOffTimeout so an untouched laptop behaves the same either side of login.
      idle.timeout = 300;

      cursor = {
        theme = "Bibata-Modern-Ice";
        # Bibata ships bitmaps at 16/28/56/88 only and XCursor snaps to the
        # nearest, so 24 actually rendered at 28. 16 is the real step down.
        size = 16;
        path = "${pkgs.bibata-cursors}/share/icons";
      };

      keyboard.layout = "us";
    };
  };

  # environment.sessionVariables sets DISPLAY=":0" for xwayland-satellite, and
  # pam_env hands it to every PAM session — including greetd's. wlroots picks its
  # backend by sniffing the environment, so it sees DISPLAY, chooses X11, finds no
  # X server at the login screen and exits; greetd then restart-loops until it hits
  # start-limit-hit, leaving a black screen. Strip DISPLAY and pin the backend so
  # the greeter always talks to DRM directly.
  services.greetd.settings.default_session.command = lib.mkForce (
    "${pkgs.coreutils}/bin/env -u DISPLAY WLR_BACKENDS=drm,libinput "
    + "${config.programs.noctalia-greeter.package}/bin/noctalia-greeter-session"
  );
}
