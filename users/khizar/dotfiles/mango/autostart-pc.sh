#!/bin/sh
# mango has no session wrapper, so bring up graphical-session.target here
# (polkit agent and friends hang off it). mango exports the env to systemd
# itself but asynchronously, so redo it synchronously first.
systemctl --user import-environment \
  WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE \
  XCURSOR_THEME XCURSOR_SIZE MANGO_INSTANCE_SIGNATURE
systemctl --user start mango-session.target

# From niri cfg/autostart-pc.kdl. xwayland-satellite is not needed —
# mango speaks xwayland natively.
noctalia-shell &
wl-paste --watch cliphist store &
equibop &
