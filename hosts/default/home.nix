{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  hfTokenPath =
    if config.age.secrets ? "huggingface-token"
    then config.age.secrets."huggingface-token".path
    else "";

  piaEnvPath =
    if config.age.secrets ? "pia-env"
    then config.age.secrets."pia-env".path
    else "";
in {
  # Hugging Face auth without interactive prompts.
  #
  # Preferred source of truth (agenix): `config.age.secrets.huggingface-token.path`
  # Fallback (legacy plaintext): `/home/tobi/nixtars/secrets/huggingface.token`
  home.activation.huggingfaceAuth = lib.hm.dag.entryAfter ["writeBoundary"] ''
    token_file="${hfTokenPath}"

    if [ -n "$token_file" ] && [ -f "$token_file" ]; then
      token="$(tr -d '\n\r' < "$token_file")"

      # huggingface_hub (hf / huggingface-cli) reads this.
      mkdir -p "$HOME/.cache/huggingface"
      ( umask 077; printf '%s' "$token" > "$HOME/.cache/huggingface/token" )
      chmod 600 "$HOME/.cache/huggingface/token" || true

      # Seed git-credential-manager so git + git-lfs can auth to Hugging Face over HTTPS
      # without prompting.
      gcm="${pkgs.git-credential-manager}/bin/git-credential-manager"
      if [ -x "$gcm" ]; then
        printf "protocol=https\nhost=huggingface.co\nusername=__token__\n\n" | "$gcm" erase >/dev/null 2>&1 || true
        printf "protocol=https\nhost=huggingface.co\nusername=__token__\npassword=%s\n\n" "$token" | "$gcm" store >/dev/null 2>&1 || true
      fi

      # Ensure git-lfs hooks/filters are installed for this user.
      if command -v git-lfs >/dev/null 2>&1; then
        git lfs install --skip-repo >/dev/null 2>&1 || true
      fi
    fi
  '';

  # agenix secrets (optional until you create `secrets/*.age`).
  # We guard with `pathExists` so evaluation doesn't fail before the files exist.
  age.secrets = let
    hfAge = ../../secrets/huggingface.token.age;
    piaAge = ../../secrets/pia.env.age;
  in
    lib.mkMerge [
      (lib.mkIf (builtins.pathExists hfAge) {
        huggingface-token.file = hfAge;
      })
      (lib.mkIf (builtins.pathExists piaAge) {
        pia-env.file = piaAge;
      })
    ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "tobi";
  home.homeDirectory = "/home/tobi";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  #home.packages = [
  # # Adds the 'hello' command to your environment. It prints a friendly
  # # "Hello, world!" when run.
  # pkgs.hello

  # # It is sometimes useful to fine-tune packages, for example, by applying
  # # overrides. You can do that directly here, just don't forget the
  # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
  # # fonts?
  # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

  # # You can also create simple shell scripts directly inside your
  # # configuration. For example, this adds a command 'my-hello' to your
  # # environment:
  # (pkgs.writeShellScriptBin "my-hello" ''
  #   echo "Hello, ${config.home.username}!"
  # '')
  # ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.-fonts
  # Keep Home Manager from managing `~/.gtkrc-2.0` at all.
  # This avoids the recurring backup collision and any future assertion failures
  # about conflicting managed targets.
  home.file = {
    ".gtkrc-2.0".enable = false;

    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #  programs.fish.enable = true;
  #  /etc/profiles/per-user/tobi/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    # Ensure git-credential-manager uses the system keyring (Secret Service).
    GCM_CREDENTIAL_STORE = "secretservice";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = lib.mkForce "gruvbox_dark_v2";
      vim_keys = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Tobias";
        email = "tobiaspucher@gmail.com";
      };

      # Store credentials in the system keyring (Secret Service) via git-credential-manager.
      credential = {
        helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        credentialStore = "secretservice";
        useHttpPath = true;
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  #programs.steam = {
  #  enable = true;
  #  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  #

  # Neovim distributions (each uses isolated config/data)
  # niri
  # Note: this file is deployed via Home Manager to `~/.config/niri/config.kdl`.
  # Changes in `./config.kdl` only take effect after `nixos-rebuild switch` (or `home-manager switch`).
  xdg.configFile."niri/config.kdl".source = lib.mkForce ./config.kdl;
  xdg.configFile."nvim".source = ./nvim-core;

  # Link Gruvbox wallpapers from the flake
  home.file."Pictures/Wallpapers/Gruvbox" = {
    source = inputs.gruvbox-wallpapers.packages.${pkgs.system}.default;
    recursive = true;
  };

  xdg.configFile."wpaperd/wallpaper.toml".text = ''
    [default]
    path = "/home/tobi/Pictures/Wallpapers/Gruvbox"
    duration = "5m"
  '';
  programs.alacritty.enable = true; # Super+T in the default setting (terminal)
  programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
  programs.swaylock = {
    enable = true; # Super+Alt+L in the default setting (screen locker)
    settings = {
      image = lib.mkForce "${config.home.homeDirectory}/nixtars/wallpapers/forest.png";
      scaling = lib.mkForce "fit";
      color = lib.mkForce "1d2021";
      indicator-radius = lib.mkForce 100;
      indicator-thickness = lib.mkForce 10;
    };
  };
  services.mako.enable = true; # notification daemon
  services.swayidle.enable = true; # idle management daemon
  services.polkit-gnome.enable = true; # polkit

  imports = [
    inputs.agenix.homeManagerModules.age
    ./waybar/default.nix
    ./pia.nix
  ];

  # nemo, udisks, auto-usb detection
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo";
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["nemo.desktop"];
      "application/x-gnome-saved-search" = ["nemo.desktop"];
    };
  };

  programs.direnv.enable = true;

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
    extraConfig = ''
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
    '';
  };

  home.packages = with pkgs; [
    hello
    direnv
    nix-direnv
    repomix
    git-lfs
    git-credential-manager
    python3Packages.huggingface-hub
    # pkgs.ralph-wiggum # Removed temporarily as it's causing build issues
    #<niri
    wpaperd
    xwayland-satellite
    networkmanagerapplet
    wl-clipboard
    slurp
    wireguard-tools
    jq
    openresolv

    (pkgs.writeShellScriptBin "pia-run" ''
      #!/usr/bin/env bash
      cd ~/Pia || { echo "Directory ~/Pia not found. Run 'nixos-rebuild switch' to fetch it."; exit 1; }

      # Source secrets from agenix
      pia_env_file="${piaEnvPath}"

      if [ -z "$pia_env_file" ] || [ ! -f "$pia_env_file" ]; then
        echo "Error: PIA secrets file not found at '$pia_env_file'. Ensure you have 'pia-env' in secrets.nix and rekeyed."
        exit 1
      fi

      set -a
      source "$pia_env_file"
      set +a

      export DISABLE_IPV6=yes
      export PIA_PF=false
      export PIA_DNS=true
      export VPN_PROTOCOL=wireguard

      # Execute the command with sudo, preserving environment variables
      sudo -E "$@"
    '')
  ];

  home.shellAliases = {
    nv = "${inputs.neovim-nightly-overlay.packages.${pkgs.system}.default}/bin/nvim";

    # PIA VPN Aliases
    pia-ldn = "pia-run PREFERRED_REGION=uk_london ./get_region.sh";
    pia-sth = "pia-run PREFERRED_REGION=uk_southampton ./get_region.sh";
    pia-man = "pia-run PREFERRED_REGION=uk_manchester ./get_region.sh";
    pia-list = "pia-run ./get_region.sh"; # Just runs the script to maybe list regions or default

    # Easy shell switching
    to-bash = "exec bash";
    to-fish = "exec fish";
    to-zsh = "exec zsh";
  };

  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;

    # Enable for whichever shell you plan to use!
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      #theme = "Abernathy";
      #theme = "Arthur";
      #theme = "Carbonfox";
      background-opacity = "0.8";
      background-blur = 20;
      font-family = "RobotoMono Nerd Font Mono";

      # Cursor animation - smooth cursor movement
      cursor-style = "bar";
      cursor-style-blink = true;
      cursor-blink-interval = 500;
      
      # Cursor trail effect shader
      custom-shader = "/home/tobi/.config/ghostty/shaders/cursor_tail.glsl";
    };
  };

  services.udiskie = {
    enable = true;
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      program_options = {
        # replace with your favorite file manager
        file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
      };
    };
  };

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        #<grim
        useGrimAdapter = true;
        # Stops warnings for using Grim
        disabledGrimWarning = true;
        #grim>

        # More settings may be found on the Flameshot Github
        # Save Path
        savePath = "/home/user/Screenshots";
        # Tray
        disabledTrayIcon = true;
        # Greeting message
        showStartupLaunchMessage = false;
        # Default file extension for screenshots (.png by default)
        saveAsFileExtension = ".png";
        # Desktop notifications
        showDesktopNotification = true;
        # Notification for cancelled screenshot
        showAbortNotification = false;
        # Whether to show the info panel in the center in GUI mode
        showHelp = true;
        # Whether to show the left side button in GUI mode
        showSidePanelButton = true;

        # Color Customization
        uiColor = "#740096";
        contrastUiColor = "#270032";
        drawColor = "#ff0000";
      };
    };
  };
}
