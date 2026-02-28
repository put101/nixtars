{ pkgs, ... }:
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
  wrapperArgs = [
    "--suffix" "PATH" ":" (pkgs.lib.makeBinPath [
      pkgs.gcc
      pkgs.gnumake
      pkgs.unzip
      pkgs.ripgrep
      pkgs.fd
      pkgs.curl
      pkgs.git
      
      # Language Servers
      pkgs.lua-language-server
      pkgs.nil # nix
      pkgs.pyright # python
      pkgs.nodePackages.typescript-language-server
      pkgs.vscode-langservers-extracted # html, css, json
    ])
  ];
}
