{ pkgs, ... }:
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
    jetbrains.idea

    # ── Launcher ──
    fuzzel

    # ── Wayland desktop ──
    swaybg
    wlsunset

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
