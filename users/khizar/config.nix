{ config, pkgs, hostName, ... }:

{
  xdg.configFile = {
    "alacritty".source = ./dotfiles/alacritty;
    "rofi".source     = ./dotfiles/rofi;

    "niri/config.kdl".source          = ./dotfiles/niri/config.kdl;
    "niri/cfg/animation.kdl".source   = ./dotfiles/niri/cfg/animation.kdl;
    "niri/cfg/autostart.kdl".source = if hostName == "nixos-pc"
      then ./dotfiles/niri/cfg/autostart-pc.kdl
      else ./dotfiles/niri/cfg/autostart-laptop.kdl;
    "niri/cfg/input.kdl".source       = ./dotfiles/niri/cfg/input.kdl;
    "niri/cfg/keybinds.kdl".source    = ./dotfiles/niri/cfg/keybinds.kdl;
    "niri/cfg/layout.kdl".source      = ./dotfiles/niri/cfg/layout.kdl;
    "niri/cfg/misc.kdl".source        = ./dotfiles/niri/cfg/misc.kdl;
    "niri/cfg/rules.kdl".source       = ./dotfiles/niri/cfg/rules.kdl;

    "niri/cfg/display.kdl".source = if hostName == "nixos-pc"
      then ./dotfiles/niri/cfg/display-pc.kdl
      else ./dotfiles/niri/cfg/display-laptop.kdl;
  };

  home.file.".p10k.zsh".source = ./dotfiles/p10k.zsh;
  dconf.enable = true;
  gtk.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = ''
      # Sourcing the p10k configuration file if it exists
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };
}
