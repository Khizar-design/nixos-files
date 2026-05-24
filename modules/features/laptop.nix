{ ... }:
{
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

  # Suppress the ELAN touchpad — it double-fires with the real input device
  services.udev.extraRules = ''
    ACTION=="add|change", ATTRS{name}=="ELAN901C:00 04F3:2EDE", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';
}
