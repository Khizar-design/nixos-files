{ inputs, pkgs, ... }:
{
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  programs.noctalia-greeter = {
    enable = true;

    # Full declarative greeter.toml (overwritten on each activation).
    # See examples/greeter.toml upstream for every key (appearance.palette, output, …).
    settings = {
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
      keyboard.layout = "us";
    };
  };
}
