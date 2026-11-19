{ config, lib, ... }:

{
  options.khizar.features.laptop = {
    enable = lib.mkEnableOption "laptop power management (TLP, auto-cpufreq, lid handling)";

    suppressElanTouchpad = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Ignore the ELAN901C touchpad node, which double-fires with the real
        input device on the ThinkPad E14.
      '';
    };

    asixEthernetFix = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Force the ASIX AX88179B USB-C ethernet adapter (0b95:1790) into USB
        config 1 so the vendor ax88179_178a driver binds. It defaults to
        config 2 (CDC NCM), where cdc_ncm never reports carrier — the link
        stays NO-CARRIER and NetworkManager marks it "unavailable".
      '';
    };
  };

  config = lib.mkIf config.khizar.features.laptop.enable {
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT       = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC        = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT     = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_AC      = "performance";
        CPU_BOOST_ON_BAT                  = 0;
        CPU_BOOST_ON_AC                   = 1;
        RUNTIME_PM_ON_BAT                 = "auto";
        RUNTIME_PM_ON_AC                  = "on";
        USB_AUTOSUSPEND                   = 1;
        WOL_DISABLE                       = "Y";
      };
    };

    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo    = "never";
        };
        charger = {
          governor = "performance";
          turbo    = "auto";
        };
      };
    };

    # TLP conflicts with power-profiles-daemon
    services.power-profiles-daemon.enable = false;

    # Lid close: suspend, then hibernate after 10 min of inactivity
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandlePowerKey = "hibernate";
    };

    # Delay before suspend transitions to hibernate
    systemd.sleep.settings.Sleep.HibernateDelaySec = "10min";

    networking.networkmanager.wifi.powersave = false;

    services.fwupd.enable = true;

    services.udev.extraRules = lib.mkMerge [
      (lib.mkIf config.khizar.features.laptop.suppressElanTouchpad ''
        ACTION=="add|change", ATTRS{name}=="ELAN901C:00 04F3:2EDE", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '')
      (lib.mkIf config.khizar.features.laptop.asixEthernetFix ''
        ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0b95", ATTR{idProduct}=="1790", ATTR{bConfigurationValue}!="1", ATTR{bConfigurationValue}="1"
      '')
    ];
  };
}
