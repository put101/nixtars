{ pkgs, inputs, config, lib, ... }:

let
  # CHANGE THIS to switch themes: "gruvbox", "nord", or "catppuccin"
  selectedTheme = "catppuccin";

  themeScheme = {
    gruvbox = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    nord = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    catppuccin = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };

  themeColors = {
    gruvbox = {
      swaylock = "1d2021";
    };
    nord = {
      swaylock = "2e3440";
    };
    catppuccin = {
      swaylock = "1e1e2e";
    };
  };
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  config.stylix = {
    enable = true;
    base16Scheme = lib.mkDefault (themeScheme.${selectedTheme} or themeScheme.gruvbox);
    image = ../../wallpapers/forest.png;
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.roboto-mono;
        name = "RobotoMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        terminal = 12;
        desktop = 10;
        popups = 10;
      };
    };

    opacity = {
      applications = 1.0;
      terminal = 0.9;
      desktop = 1.0;
      popups = 1.0;
    };
  };
}
