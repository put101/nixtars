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

    #nix-pia-vpn = {
     #url = "github:rcambrj/nix-pia-vpn";
     #inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = { self, nixpkgs, ... }@inputs: {
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
  };
}
