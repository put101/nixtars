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
                "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
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

    ralph-src = {
      url = "github:mikeyobrien/ralph-orchestrator";
      flake = false;
    };

    ralph-tui-src = {
      url = "github:subsy/ralph-tui";
      flake = false;
    };

    #nix-pia-vpn = {
     #url = "github:rcambrj/nix-pia-vpn";
     #inputs.nixpkgs.follows = "nixpkgs";
    #};

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    #niri
    niri-session-manager.url = "github:MTeaHead/niri-session-manager";


    #inputs.zotero-nix.url = "github:camillemndn/zotero-nix";

    openai-codex = {
      url = "github:GutMutCode/openai-codex-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lmstudio.url = "github:tomsch/lmstudio-nix";

  };

  outputs = { self, nixpkgs, home-manager, lazyvim, niri-session-manager,
        lmstudio, ... }@inputs: {
    overlays.default = final: prev: {
      ralph-tui = final.callPackage ./pkgs/ralph-tui.nix {
        src = inputs.ralph-tui-src;
      };
    };
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
