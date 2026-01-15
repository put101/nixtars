{
  description = "Nixos config flake";
  nixConfig = { 
  	extra-substituters = [
	  "https://cache.nixos.org"
          "https://nix-community.cachix.org"
	  "https://cuda-maintainers.cachix.org"
	];
	extra-trusted-public-keys = [
	      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
		"cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
	];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };



    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #home-manager.url = "github:nix-community/home-manager";
    lazyvim.url = "github:pfassina/lazyvim-nix";

    #nix-pia-vpn = {
     #url = "github:rcambrj/nix-pia-vpn";
     #inputs.nixpkgs.follows = "nixpkgs";
    #};

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #niri
    niri-session-manager.url = "github:MTeaHead/niri-session-manager";


    #inputs.zotero-nix.url = "github:camillemndn/zotero-nix";


  };

  outputs = { self, nixpkgs, home-manager, lazyvim, niri-session-manager, ... }@inputs: {
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations.nixtars = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/default/configuration.nix
        inputs.home-manager.nixosModules.default
	  #inputs.nix-pia-vpn.nixosModules.default
      ];
    };

    #niri
    nixosConfigurations = {
      yourHost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # This is not a complete NixOS configuration; reference your normal configuration here.
          # Import the module
          niri-session-manager.nixosModules.niri-session-manager

          #<zotero
          #environment.systemPackages = [ zotero-nix.packages.${system}.default ];
          #zotero>

          ({
            # Enable the service
            services.niri-session-manager.enable = true;
            # Optional: Configure the service
            services.niri-session-manager.settings = {
              save-interval = 30;  # Save every 30 minutes
              max-backup-count = 3;  # Keep 3 most recent backups
            };
          })
        ];
      };
    };

  };
}
