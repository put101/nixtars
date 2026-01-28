{ pkgs, lib, config, ... }:

{
  # Disable Stylix styling for Waybar so we can use our own custom config
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;
    # We reference the configuration file and style sheet directly.
    # This makes it easier to copy-paste examples from the Waybar Wiki (which are in JSON).
  };

  # Link the config and style files to the correct location in ~/.config/waybar/
  xdg.configFile."waybar/config".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
}