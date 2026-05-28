{ pkgs,inputs,  ... }:
{
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
    equibop
    lf
    obsidian

    # ── Toolkit ──
    vlc
    btop
    rsync
    fastfetch
    bash-completion
    openssh
    unzip
    libreoffice-fresh
    teams-for-linux
    obs-studio
    tree
    jetbrains.idea
    inputs.vm-curator.packages.${pkgs.system}.default
    poppler-utils

    # ── Launcher ──
    fuzzel
    rofi
    
    # ── Wayland desktop ──
    swaybg
    wlsunset
    xwayland-satellite

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
  
  programs.zsh.enable = true;
}
