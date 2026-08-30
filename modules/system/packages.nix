{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.khizar.packages;

  group = name: description: lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "${description} (see modules/system/packages.nix for the list).";
  };
in
{
  options.khizar.packages = {
    core.enable        = group "core" "Base CLI tooling";
    desktop.enable     = group "desktop" "Wayland desktop bits: shell, launcher, file manager, clipboard";
    browser.enable     = group "browser" "Zen Browser";
    dev.enable         = group "dev" "Editors, IDEs, Node/Python toolchains";
    media.enable       = group "media" "Players, OBS, anime/podcast CLIs";
    office.enable      = group "office" "LibreOffice, Obsidian, Slack, Teams";
    ai.enable          = group "ai" "LM Studio and Claude Code";
    appearance.enable  = group "appearance" "GTK theme and cursor packages";
    fonts.enable       = group "fonts" "System font set";
    security.enable    = group "security" "Wireshark with a dumpcap setcap wrapper";

    extra = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Host-specific extras that do not belong to a group.";
    };
  };

  config = lib.mkMerge [
    {
      nixpkgs.config.allowUnfree = true;
      programs.zsh.enable = true;
      environment.systemPackages = cfg.extra;
    }

    (lib.mkIf cfg.core.enable {
      environment.systemPackages = with pkgs; [
        ethtool
        vim
        neovim
        fastfetch
        fetch
        wget
        git
        tree
        unzip
        rsync
        btop
        openssh
        bash-completion
      ];
    })

    (lib.mkIf cfg.desktop.enable {
      environment.systemPackages = with pkgs; [
        alacritty
        noctalia-shell
        rofi
        thunar
        tumbler
        swaybg
        wlsunset
        xwayland-satellite
        wl-clipboard
        cliphist
        # niri had screenshots built in; mango does not.
        grim
        slurp
      ];
    })

    (lib.mkIf cfg.browser.enable {
      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })

    (lib.mkIf cfg.dev.enable {
      environment.systemPackages = with pkgs; [
        nodejs_22
        pnpm
        python3
        gnumake
        jetbrains.idea
        vscode
        inputs.vm-curator.packages.${pkgs.system}.default
      ];
    })

    (lib.mkIf cfg.media.enable {
      environment.systemPackages = with pkgs; [
        vlc
        obs-studio
        ani-cli
        ani-skip
        castero
        poppler-utils
      ];
    })

    (lib.mkIf cfg.office.enable {
      environment.systemPackages = with pkgs; [
        libreoffice-stable
        obsidian
        teams-for-linux
        (slack.overrideAttrs (old: {
          installPhase = old.installPhase + ''
            wrapProgram $out/bin/slack \
              --add-flags "--enable-features=WebRTCPipeWireCapturer"
          '';
        }))
      ];
    })

    (lib.mkIf cfg.ai.enable {
      environment.systemPackages = with pkgs; [
        claude-code
        lmstudio
      ];
    })

    (lib.mkIf cfg.appearance.enable {
      environment.systemPackages = with pkgs; [
        capitaine-cursors
        adw-gtk3
      ];
    })

    (lib.mkIf cfg.fonts.enable {
      fonts.fontDir.enable = true;
      fonts.packages = with pkgs; [
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
    })

    (lib.mkIf cfg.security.enable {
      # Installs wireshark, creates the 'wireshark' group, and sets up a setcap
      # wrapper for dumpcap so group members can capture without root.
      programs.wireshark = {
        enable = true;
        package = pkgs.wireshark; # default is wireshark-cli (no GUI)
      };
    })
  ];
}
