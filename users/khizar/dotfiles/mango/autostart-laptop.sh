#!/bin/sh
# mango has no session wrapper, so bring up graphical-session.target here
# (polkit agent and friends hang off it). mango exports the env to systemd
# itself but asynchronously, so redo it synchronously first.
systemctl --user import-environment \
  WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE \
  XCURSOR_THEME XCURSOR_SIZE MANGO_INSTANCE_SIGNATURE
systemctl --user start mango-session.target

# From niri cfg/autostart-laptop.kdl. xwayland-satellite is not needed —
# mango speaks xwayland natively.
# noctalia 4.7.7 picks its compositor backend from XDG_CURRENT_DESKTOP: anything
# containing "mango" selects MangoService, which talks the DWL IPC protocol.
# mango 0.16.1 does not advertise zdwl_ipc_manager_v2 — only ext_workspace_manager_v1
# — so that backend reports no workspaces and the bar's Workspace widget is blank.
# Hiding the name drops noctalia to its generic ext-workspace backend, which mango
# does speak. Revisit once noctalia's MangoService moves to ext-workspace.
XDG_CURRENT_DESKTOP=wlroots noctalia-shell &

wl-paste --watch cliphist store &
