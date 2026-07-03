{ pkgs, ... }:

# ActivityWatch — automatic, fully-local time tracking.
#
#   aw-server         serves the database + bundled web UI at http://localhost:5600
#                     (from the `activitywatch` bundle — the standalone
#                     aw-server-rust package does NOT ship the web UI)
#   awatcher          Wayland-native watcher: tracks the focused window AND
#                     idle/AFK state via niri's wlr-foreign-toplevel +
#                     ext-idle-notify protocols (the stock X11 watchers don't
#                     work under Wayland/niri).
#
# Both run as systemd user services bound to graphical-session.target, so they
# start/stop with the niri session and restart on failure.
#
# After a rebuild, open http://localhost:5600 to see data and set up
# Study/Leisure category rules. For per-tab (URL) tracking in zen-browser,
# also install the "aw-watcher-web" add-on from Firefox Add-ons.

{
  home.packages = with pkgs; [
    activitywatch
    awatcher
  ];

  systemd.user.services.aw-server = {
    Unit = {
      Description = "ActivityWatch server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.activitywatch}/bin/aw-server";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.awatcher = {
    Unit = {
      Description = "ActivityWatch Wayland watcher (window + idle)";
      Requires = [ "aw-server.service" ];
      After = [ "aw-server.service" "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.awatcher}/bin/awatcher";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
