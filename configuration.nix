{ config, pkgs, inputs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  # ─── Boot ───────────────────────────────────────────────────────────────
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ─── Networking ─────────────────────────────────────────────────────────
  networking.hostName = "nixos-laptop";
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # ─── Time & Locale ──────────────────────────────────────────────────────
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ─── AMD GPU ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  # ─── Power Management (laptop) ──────────────────────────────────────────
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT  = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC   = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT  = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_AC   = "performance";
      CPU_BOOST_ON_BAT = 0;
      CPU_BOOST_ON_AC  = 1;
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ON_AC  = "on";
      USB_AUTOSUSPEND = 1;
      WOL_DISABLE = "Y";
    };
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # TLP conflicts with power-profiles-daemon
  services.power-profiles-daemon.enable = false;

  # ─── Noctalia Dependencies ───────────────────────────────────────────────
  services.upower.enable = true;

  # ─── Bluetooth ──────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;

  # ─── Audio (PipeWire) ───────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  # ─── Niri (Wayland compositor) ──────────────────────────────────────────
  programs.niri.enable = true;
  services.libinput.enable = true;

  # ─── Display Manager (greetd → niri) ────────────────────────────────────
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.niri}/bin/niri-session";
      user = "khizar";
    };
  };

  # ─── XDG / Portal ───────────────────────────────────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.dbus.enable = true;

  # ─── Flatpak ────────────────────────────────────────────────────────────
  services.flatpak.enable = true;

  # ─── Tailscale ──────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ─── Firewall ───────────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  # ─── User ───────────────────────────────────────────────────────────────
  users.users.khizar = {
    isNormalUser = true;
    description = "Khizar";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.bash;
    packages = with pkgs; [];
  };

  # ─── Packages ───────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # ── Core ──
    vim
    neovim
    wget
    git
    alacritty
    noctalia-shell
    claude-code

    # ── Toolkit ──
    vlc
    btop
    rsync
    fastfetch
    bash-completion
    openssh
    unzip
    libreoffice-fresh

    # ── Launcher ──
    fuzzel

    # ── Wayland desktop ──
    swaybg        # wallpaper setter (used by noctalia)
    wlsunset      # night-light / blue-light filter

    # ── Appearance ──
    capitaine-cursors
    adw-gtk3

    # ── Fonts ──
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    cantarell-fonts
    liberation_ttf
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    fira-code
    libre-baskerville
  ];

  # ─── Fonts ──────────────────────────────────────────────────────────────
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    fira-code
    libre-baskerville
    cantarell-fonts
  ];

  # ─── Wayland Environment Variables ──────────────────────────────────────
  environment.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM              = "wayland";
    QT_QPA_PLATFORMTHEME         = "gtk3";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP          = "niri";
    XDG_SESSION_TYPE             = "wayland";
  };

  # ─── Touchscreen (disabled) ─────────────────────────────────────────────
  services.udev.extraRules = ''
    ACTION=="add|change", ATTRS{name}=="ELAN901C:00 04F3:2EDE", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # ─── GTK / dconf ────────────────────────────────────────────────────────
  programs.dconf.enable = true;

  # ─── Nix settings ───────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ─── NAS mount ──────────────────────────────────────────────────────────
  fileSystems."/mnt/nas" = {
    device = "//100.77.111.96/Public";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-secrets"
      "uid=1000"
      "gid=100"
      "vers=3.0"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
    ];
  };

  system.stateVersion = "25.11";
}
