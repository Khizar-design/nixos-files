{ inputs, hostName, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs hostName; };
    
    # Points to your user configuration folder
    users.khizar = import ../../users/khizar; 
  };
}
