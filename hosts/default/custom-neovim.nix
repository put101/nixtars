{ pkgs, lib, config, ... }:
let
  # Configuration for your custom Neovim distribution
  # Change this to point to your fork
  customNeovimDir = "${config.home.homeDirectory}/my-neovim";
  
  # Wrapper script that sets up the environment
  custom-nvim = pkgs.writeShellApplication {
    name = "nvim-custom";
    runtimeInputs = with pkgs; [
      # Core dependencies most Lua distros need
      git
      gcc
      gnumake
      unzip
      wget
      curl
      ripgrep
      fd
      fzf
      nodePackages.npm
      nodejs
      cargo
      rustc
      python3
      lua5_1
      luarocks
      
      # AstroNvim recommended tools
      lazygit
      bottom
      xclip
      xsel
      gdu
      
      # Language servers (common ones)
      lua-language-server
      nil # nix lsp
      
      # Tree-sitter
      tree-sitter
      
      # Neovim itself
      neovim
    ];
    text = ''
      # Set up isolated environment for your custom Neovim
      export NVIM_APPNAME="nvim-custom"
      export CUSTOM_NVIM_DIR="${customNeovimDir}"
      
      # Add cargo/bin to PATH for Rust-based plugins
      export PATH="$HOME/.cargo/bin:$PATH"
      
      # Add npm global packages to PATH
      export PATH="$HOME/.npm-global/bin:$PATH"
      
      # Ensure node_modules/.bin is in PATH
      export PATH="$CUSTOM_NVIM_DIR/node_modules/.bin:$PATH"
      
      # Set up data directories
      export XDG_DATA_HOME="${config.home.homeDirectory}/.local/share"
      export XDG_CONFIG_HOME="${config.home.homeDirectory}/.config"
      export XDG_CACHE_HOME="${config.home.homeDirectory}/.cache"
      
      # Check if the custom config exists
      if [ ! -d "$CUSTOM_NVIM_DIR" ]; then
        echo "❌ Custom Neovim directory not found: $CUSTOM_NVIM_DIR"
        echo ""
        echo "To set up your custom Neovim distribution:"
        echo "1. Fork your preferred distro (e.g., LazyVim, NvChad, AstroNvim) on GitHub"
        echo "2. Clone it: git clone https://github.com/YOUR_USERNAME/YOUR_FORK.git ~/my-neovim"
        echo "3. Run: nvim-custom"
        echo ""
        echo "Or create a minimal setup:"
        echo "  mkdir -p ~/my-neovim"
        echo "  cd ~/my-neovim"
        echo "  git init"
        echo "  # Copy your init.lua or distro files here"
        exit 1
      fi
      
      # Link the config if not already linked
      CONFIG_LINK="$XDG_CONFIG_HOME/nvim-custom"
      if [ ! -L "$CONFIG_LINK" ] || [ "$(readlink -f "$CONFIG_LINK")" != "$CUSTOM_NVIM_DIR" ]; then
        rm -f "$CONFIG_LINK"
        ln -s "$CUSTOM_NVIM_DIR" "$CONFIG_LINK"
        echo "🔗 Linked $CUSTOM_NVIM_DIR -> $CONFIG_LINK"
      fi
      
      # Run Neovim with the custom config
      exec ${pkgs.neovim}/bin/nvim "$@"
    '';
  };
in
{
  home.packages = [ custom-nvim ];
  
  # Optional: Create a template starter script
  home.file.".local/bin/nvim-custom-init" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Initialize a new custom Neovim distribution
      
      DISTRO=''${1:-lazyvim}
      TARGET_DIR="$HOME/my-neovim"
      
      if [ -d "$TARGET_DIR" ] && [ "$(ls -A $TARGET_DIR)" ]; then
        echo "⚠️  $TARGET_DIR already exists and is not empty"
        read -p "Remove it and continue? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
          rm -rf "$TARGET_DIR"
        else
          exit 1
        fi
      fi
      
      mkdir -p "$TARGET_DIR"
      cd "$TARGET_DIR"
      
      case $DISTRO in
        lazyvim|lvim)
          echo "🚀 Setting up LazyVim..."
          git clone https://github.com/LazyVim/starter.git "$TARGET_DIR"
          rm -rf .git
          git init
          echo "✅ LazyVim template cloned. Edit lua/config/*.lua to customize."
          ;;
        nvchad)
          echo "🚀 Setting up NvChad..."
          git clone https://github.com/NvChad/starter.git "$TARGET_DIR"
          rm -rf .git
          git init
          echo "✅ NvChad template cloned. Edit lua/configs/*.lua to customize."
          ;;
        astronvim|astro)
          echo "🚀 Setting up AstroNvim..."
          git clone --depth 1 https://github.com/AstroNvim/template "$TARGET_DIR"
          rm -rf .git
          git init
          echo "✅ AstroNvim template cloned. Edit lua/plugins/*.lua to customize."
          ;;
        kickstart)
          echo "🚀 Setting up kickstart.nvim..."
          curl -fsSL https://raw.githubusercontent.com/nvim-lua/kickstart.nvim/master/init.lua -o "$TARGET_DIR/init.lua"
          mkdir -p "$TARGET_DIR/lua"
          echo "✅ kickstart.nvim init.lua downloaded."
          ;;
        *)
          echo "❌ Unknown distro: $DISTRO"
          echo "Available: lazyvim, nvchad, astronvim, kickstart"
          exit 1
          ;;
      esac
      
      echo ""
      echo "📝 Next steps:"
      echo "1. cd $TARGET_DIR"
      echo "2. git add . && git commit -m 'Initial commit'"
      echo "3. gh repo create my-neovim --private --source=. --push  # Optional: push to GitHub"
      echo "4. nvim-custom  # Launch your custom Neovim!"
    '';
  };
}
