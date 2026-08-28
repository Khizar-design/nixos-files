{ config, inputs, lib, pkgs, ... }:
{
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  programs.noctalia-greeter = {
    enable = true;

    # Full declarative greeter.toml (overwritten on each activation).
    # See examples/greeter.toml upstream for every key (appearance.palette, output, …).
    settings = {
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
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
