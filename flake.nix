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

    agenix.url = "github:ryantm/agenix";

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

    gruvbox-wallpapers.url = "github:AngelJumbo/gruvbox-wallpapers";


    #inputs.zotero-nix.url = "github:camillemndn/zotero-nix";

    openai-codex = {
      url = "github:GutMutCode/openai-codex-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lmstudio.url = "github:tomsch/lmstudio-nix";

    opencode-ralph-wiggum-src = {
      url = "github:Th0rgal/opencode-ralph-wiggum";
      flake = false;
    };

  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , agenix
    , lazyvim
    , niri-session-manager
    , lmstudio
    , ...
    }@inputs: {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      overlays.default = final: prev: {
        ralph-tui = final.callPackage ./pkgs/ralph-tui.nix {
          src = inputs.ralph-tui-src;
        };

        ralph-wiggum = final.callPackage ./pkgs/ralph-wiggum.nix {
          src = inputs.opencode-ralph-wiggum-src;
          opencode = final.opencode;
        };

        # Ollama 0.15.x override (nixpkgs may lag behind)
        ollama =
          let
            version = "0.15.2";
          in
          prev.ollama.overrideAttrs (old: {
            inherit version;
            src = prev.fetchFromGitHub {
              owner = "ollama";
              repo = "ollama";
              tag = "v${version}";
              hash = "sha256-hfEuVWMmayAO26EV6fu7lRWEL3Es9wyN9sMdm5I+NJE=";
            };
            vendorHash = "sha256-WdHAjCD20eLj0d9v1K6VYP8vJ+IZ8BEZ3CciYLLMtxc=";
          });

        ollama-cuda =
          let
            version = "0.15.2";
          in
          prev.ollama-cuda.overrideAttrs (old: {
            inherit version;
            src = prev.fetchFromGitHub {
              owner = "ollama";
              repo = "ollama";
              tag = "v${version}";
              hash = "sha256-hfEuVWMmayAO26EV6fu7lRWEL3Es9wyN9sMdm5I+NJE=";
            };
            vendorHash = "sha256-WdHAjCD20eLj0d9v1K6VYP8vJ+IZ8BEZ3CciYLLMtxc=";
          });
      };

      # use "nixos", or your hostname as the name of the configuration
      # it's a better practice than "default" shown in the video
      nixosConfigurations.nixtars = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.agenix.nixosModules.default
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
          #inputs.nix-pia-vpn.nixosModules.default
        ];
      };
    };
}
