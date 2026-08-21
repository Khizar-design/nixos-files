{
  description = "NixOS with niri + noctalia";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    vm-curator.url = "github:mroboff/vm-curator";

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    openlogi = {
      url = "github:AprilNEA/OpenLogi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, ...}: {
    nixosConfigurations = {
      nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; hostName = "nixos-laptop"; };
        modules = [
          ./modules/system
          ./hosts/nixos-laptop
          ./modules/home-manager
	      ];
      };

      nixos-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; hostName = "nixos-pc"; };
        modules = [
          ./modules/system
          ./hosts/nixos-PC
          ./modules/home-manager
	      ];
      };

    };
  };
}
