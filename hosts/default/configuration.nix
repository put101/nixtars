# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix
    ./agenix.nix
  ];

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;

  services.blueman.enable = true;
  services.libinput.mouse.horizontalScrolling = true;

  nix.settings = {
    trusted-users = ["root" "tobi"];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://claude-code.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="

      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  #services.pia-vpn = {
  #  enable = true;
  #  certificateFile = toString ../../secrets/ca.rsa.4096.crt;
  #  environmentFile = toString ../../secrets/pia.env;
  #};

  hardware.graphics.enable = true;
  hardware.nvidia.open = false;
  services.xserver.videoDrivers = ["nvidia"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # SumAstroNvim configuration (soft disabled for now)
  # sumAstroNvim = {
  #   username = "tobi";
  #   nerdfont = pkgs.nerd-fonts.jetbrains-mono;
  #   nodePackage = pkgs.nodejs;
  #   pythonPackage = pkgs.python3;
  # };

  networking.hostName = "nixtars"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Add this line to force Niri selected by default
  services.displayManager.defaultSession = "niri";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "at";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Secret Service (keyring) for non-Plasma sessions like Niri.
  # Needed for tools like git-credential-manager (secure credential storage).
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  services.udisks2.enable = true;

  fonts = {
    packages = with pkgs;
      [
        noto-fonts
        liberation_ttf
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

services.deluge = {
	enable = true;
	web.enable = true;  # Enables the web interface
	openFirewall = true; # Opens the firewall for Deluge
	};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tobi = {
    isNormalUser = true;
    description = "tobi";
    shell = pkgs.fish;
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {inherit inputs;};

    # Backup pre-existing dotfiles instead of failing activation.
    # Example: ~/.gtkrc-2.0 -> ~/.gtkrc-2.0.hm-bak
    backupFileExtension = "hm-bak";

    users = {
      "tobi" = import ./home.nix;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.direnv.enable = true;

  programs.fish.enable = true;

  # uv, numpy import error: libstdc++
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    (lib.getLib pkgs.stdenv.cc.cc) # provides libstdc++.so.6 and libgcc_s.so.1
    pkgs.zlib
    pkgs.libffi
    pkgs.openssl
    pkgs.glibc
  ];

  #niri
  programs.niri.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.self.overlays.default
    inputs.neovim-nightly-overlay.overlays.default
  ];

  #nixpkgs.config.cudaSupport = true;

  # Fix uv standalone Python SSL on NixOS.
  # uv's Python looks for CA certificates at /etc/ssl/cert.pem, but NixOS typically provides
  # /etc/ssl/certs/ca-bundle.crt (or /etc/ssl/certs/ca-certificates.crt).
  # This creates /etc/ssl/cert.pem as a symlink managed by NixOS.
  environment.etc."ssl/cert.pem".source = "/etc/ssl/certs/ca-bundle.crt";

  environment.shellAliases = {
    ll = "ls -alF";
    gs = "git status";
    nv = "nvim";
    y = "yazi";
    build = "sudo nixos-rebuild switch --flake .#nixtars";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    cachix
    inputs.agenix.packages.${pkgs.system}.default
    age
    wget
    jq
    lsof
    tree
    gh
    just
    brightnessctl
    docker
    docker-color-output
    oxker
    vim
    # neovim (soft disabled for now)
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
    xsel
    vscode
    tealdeer
    xclip
    bat
    unetbootin
    fastfetch
    python3
    uv
    microsoft-edge
    brave
    signal-desktop
    #jetbrains.pycharm-professional
    obsidian
    discord

    #<fish
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fzf
    fishPlugins.grc
    grc
    #fish>

    wireguard-tools
    gemini-cli
    copilot-cli
    tmux
    opencode

    ralph-tui
    ralph-wiggum
    beads
    bubblewrap
    libnotify
    yazi
    lazygit

    gparted

    # Use older anki version that works with addons
    (inputs.nixpkgs-anki.legacyPackages.${pkgs.system}.anki.withAddons [
      (inputs.nixpkgs-anki.legacyPackages.${pkgs.system}.ankiAddons.anki-connect.withConfig {
        config = {
          webCorsOriginList = [
            "http://localhost"
            "app://obsidian.md"
          ];
        };
      })
    ])
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.nccl

    # screenshot plasma issue -> use https://wiki.nixos.org/wiki/Flameshot
    #grim

    #<datanvim
    gcc
    gnumake
    pkg-config
    lua5_1
    luarocks
    imagemagick
    luaPackages.luarocks
    #datanvim>

    zoom-us
    yt-dlp

    (pkgs.ffmpeg-full.override {withUnfree = true;})

    # llm stuff
    ollama
    llama-cpp
    inputs.lmstudio.packages.x86_64-linux.default
    open-webui
    (callPackage ./ralph.nix {src = inputs.ralph-src;})
    claude-code
    pdfgrep

    baobab
    kdePackages.filelight
    ncdu
    parallel-disk-usage
    pciutils
    usbutils

    # Neovim runtime deps (for mason in AstroNvim)
    unzip
    go

    localsend
  ];

  services.ollama = {
    enable = true;
    # acceleration = "cuda"; # REMOVED: Deprecated option
    package = pkgs.ollama-cuda; # ADDED: New method for GPU support
    # Optional: preload models, see https://ollama.com/library
    loadModels = ["deepseek-r1:1.5b"];
  };

  services.open-webui.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
