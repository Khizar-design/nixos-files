{ pkgs,inputs,  ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # ── Core ──
    ethtool
    vim
    neovim
    hyfetch
    wget
    git
    alacritty
    noctalia-shell
    claude-code
    thunar
    tumbler
    obsidian
    (slack.overrideAttrs (old: {
      installPhase = old.installPhase + ''
        wrapProgram $out/bin/slack \
          --add-flags "--enable-features=WebRTCPipeWireCapturer"
      '';
    }))
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # ── Node.js dev ──
    nodejs_22
    pnpm
    python3
    gnumake

    # ── Toolkit ──
    vlc
    btop
    rsync
    bash-completion
    openssh
    unzip
    libreoffice-fresh
    teams-for-linux
    obs-studio
    tree
    jetbrains.idea
    vscode
    inputs.vm-curator.packages.${pkgs.system}.default
    poppler-utils
    lmstudio

    # ── Security ──
    wireshark

    # ── Launcher ──
    rofi
    
    # ── Wayland desktop ──
    swaybg
    wlsunset
    xwayland-satellite
    wl-clipboard
    cliphist

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
