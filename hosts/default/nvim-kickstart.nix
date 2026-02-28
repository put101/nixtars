{ pkgs, ... }:
let
  neovim-wrapped = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    wrapperArgs = [
      "--suffix" "PATH" ":" (pkgs.lib.makeBinPath [
        pkgs.git
        pkgs.gcc
        pkgs.gnumake
        pkgs.unzip
        pkgs.ripgrep
        pkgs.fd
        pkgs.curl
        pkgs.tree-sitter
        pkgs.lua-language-server
        pkgs.nil # Nix LSP
        pkgs.nodejs # for some LSPs
      ])
    ];
  };
in
pkgs.runCommand "nvim-kickstart" { } ''
  mkdir -p $out/bin
  ln -s ${neovim-wrapped}/bin/nvim $out/bin/nvim-kickstart
''
