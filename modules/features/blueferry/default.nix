{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.blueferry;

  # BlueFerry opens its encrypted store and builds its libnotify sink exactly
  # once at startup and never retries (event_dispatcher.py `setup()` bails on
  # `if self.sinks: return`). Under niri both the notification daemon and
  # gnome-keyring come up as compositor-spawned scopes with no ordering
  # relative to default.target, so a boot-time start can beat them by a second
  # and leave the daemon alive-but-useless: no popups, no history, no contacts,
  # while still logging "ready". Hold ExecStart until both names own the bus.
  waitForSession = pkgs.writeShellScript "blueferry-wait-session" ''
    owned() {
      ${pkgs.systemd}/bin/busctl --user --quiet call \
        org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus \
        GetNameOwner s "$1" >/dev/null 2>&1
    }

    for _ in $(${pkgs.coreutils}/bin/seq 1 60); do
      if owned org.freedesktop.Notifications && owned org.freedesktop.secrets; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 0.5
    done

    # A degraded daemon still beats no daemon; leave a breadcrumb either way.
    echo "blueferry: session bus names absent after 30s; starting degraded" >&2
    exit 0
  '';
in
{
  options.services.blueferry = {
    enable = lib.mkEnableOption "BlueFerry, the iPhone-to-Linux Bluetooth message bridge";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      description = "The blueferry package to use.";
    };

    experimentalBluez = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run bluetoothd with -E. BlueFerry needs BlueZ's experimental
        Bearer.LE1/Bearer.BREDR1 interfaces to keep ANCS notifications on LE
        while MAP and PBAP use BR/EDR. Without it messages and contacts still
        work but iPhone system notifications do not.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    environment.systemPackages = [ cfg.package ];

    # Session-bus activation for the per-user backend.
    services.dbus.packages = [ cfg.package ];

    # Fresh admin auth for the one system unit BlueFerry can trigger.
    environment.etc."polkit-1/rules.d/49-blueferry-cod.rules".source =
      "${cfg.package}/share/polkit-1/rules.d/49-blueferry-cod.rules";

    systemd.user.services.blueferry = {
      description = "BlueFerry — iPhone↔Linux Bluetooth bridge";
      documentation = [ "https://github.com/erikwb/blueferry" ];
      wantedBy = [ "default.target" ];

      # Only users who finished pairing have config and should start a daemon.
      unitConfig.ConditionPathExists = "%h/.config/blueferry/local.env";

      serviceConfig = {
        Type = "dbus";
        BusName = "io.weirdware.BlueFerry";
        ExecStartPre = "${waitForSession}";
        ExecStart = "${cfg.package}/bin/blueferry run";
        Restart = "on-failure";
        # EX_TEMPFAIL is the daemon's deliberate upgrade-restart request.
        RestartForceExitStatus = 75;
        RestartSec = 5;
        TimeoutStopSec = 180;
        UMask = "0077";

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        # The backend reaches Bluetooth only through local D-Bus sockets.
        RestrictAddressFamilies = "AF_UNIX";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
      };
    };

    # Started on demand (polkit-authorized) to set the adapter class of device.
    systemd.services."blueferry-btmgmt-set-class@" = {
      description = "BlueFerry set Bluetooth adapter hci%i class with btmgmt";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/libexec/blueferry/blueferry-set-cod %i";
        NoNewPrivileges = true;
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
        ];
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_BLUETOOTH";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
      };
    };

    # The upstream packages ship a bluetooth.service drop-in for this; on NixOS
    # the module owns ExecStart outright, so override it.
    systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkIf cfg.experimentalBluez (
      lib.mkForce [
        ""
        "${config.hardware.bluetooth.package}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf -E"
      ]
    );
  };
}
