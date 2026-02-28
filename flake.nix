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
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-anki.url = "github:nixos/nixpkgs/3cbadb8d8db0495065347b709baab421139bf6f6";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    agenix.url = "github:ryantm/agenix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

        # Pin microsoft-edge to version 144 (145 download failing)
        microsoft-edge =
          prev.microsoft-edge.overrideAttrs (old: rec {
            version = "144.0.3719.104";
            src = prev.fetchurl {
              url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${version}-1_amd64.deb";
              sha256 = "x+p8wte4KFoWiH9aIk9ym282Hb+Y1369YoxEXtgokVA=";
            };
          });

        # Upgrade opencode to v1.1.51 (latest release)
        opencode =
          let
            version = "1.1.51";
            src = prev.fetchFromGitHub {
              owner = "anomalyco";
              repo = "opencode";
              tag = "v${version}";
              hash = "sha256-i9KR5n6bT0p7xLErlgaq2TAj/B7ZbLd9a+4Czg8q/cI=";
            };
          in
          prev.opencode.overrideAttrs (old: {
            inherit version src;
            node_modules = old.node_modules.overrideAttrs (nmOld: {
              inherit src version;
              outputHash = "sha256-tPDRjMcfGWC7TJaQHa3mt7PsZ6Gr5l4lMUOSXoozqoU=";
            });
          });
      };

      # use "nixos", or your hostname as the name of the configuration
      # it's a better practice than "default" shown in the video
      nixosConfigurations.nixtars = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit (inputs) nixpkgs-unstable;
        };
        modules = [
          inputs.agenix.nixosModules.default
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
          #inputs.nix-pia-vpn.nixosModules.default
        ];
      };
    };
}
