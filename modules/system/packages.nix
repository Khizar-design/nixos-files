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

      # noctalia 5.0.0 (nixpkgs' `noctalia`, currently 5.0.0-betaX, fetched
      # prebuilt from cache.nixos.org) wrapped under the old `noctalia-shell`
      # command name, so mango's and niri's dotfiles (keybinds, autostart)
      # keep calling `noctalia-shell` unmodified. Tracks whatever nixpkgs
      # currently packages as `noctalia`, including its eventual stable release.
      #
      # v5 dropped the v4 `ipc call <target> <action>` vocabulary for `msg
      # <command>` (see `noctalia msg --help`). keybinds.conf/keybinds.kdl still
      # spawn the v4 form, so this shim translates each call site used there
      # into its v5 equivalent instead of editing those dotfiles, which are
      # shared with hosts still on v4.
      nixpkgs.overlays = [
        (final: prev: {
          noctalia-shell = final.writeShellScriptBin "noctalia-shell" ''
            bin=${final.noctalia}/bin/noctalia

            if [ "$1" = "ipc" ] && [ "$2" = "call" ]; then
              shift 2
              case "$1 $2" in
                "launcher toggle")     exec "$bin" msg panel-toggle launcher ;;
                "lockScreen lock")     exec "$bin" msg session lock ;;
                "sessionMenu toggle")  exec "$bin" msg panel-toggle session ;;
                "launcher clipboard")  exec "$bin" msg panel-toggle clipboard ;;
                "volume increase")     exec "$bin" msg volume-up ;;
                "volume decrease")     exec "$bin" msg volume-down ;;
                "volume muteOutput")   exec "$bin" msg volume-mute ;;
                "volume muteInput")    exec "$bin" msg mic-mute ;;
                "media next")          exec "$bin" msg media next ;;
                "media previous")      exec "$bin" msg media previous ;;
                "media playPause")     exec "$bin" msg media toggle ;;
                "brightness increase") exec "$bin" msg brightness-up ;;
                "brightness decrease") exec "$bin" msg brightness-down ;;
                "monitors off")        exec "$bin" msg dpms-off ;;
                *)
                  echo "noctalia-shell compat shim: no v5 mapping for 'ipc call $1 $2'" >&2
                  exit 1
                  ;;
              esac
            fi

            exec "$bin" "$@"
          '';
        })
      ];
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
