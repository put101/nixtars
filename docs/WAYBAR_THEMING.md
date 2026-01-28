# Waybar Customization Guide

This guide explains how to customize the Waybar (the status bar at the top of the screen) in the **Nixtars** configuration.

## Overview

The Waybar configuration has been decoupled from the main Nix logic to allow for easier customization and "copy-paste" compatibility with online examples.

*   **Config File:** `hosts/default/waybar/config.jsonc` (Standard JSON configuration)
*   **Style File:** `hosts/default/waybar/style.css` (Standard CSS styling)
*   **Nix Glue:** `hosts/default/waybar/default.nix` (Tells Home Manager to use the above two files)

## How to Change Themes

You can find hundreds of pre-made Waybar themes on:
*   [Waybar Wiki Examples](https://github.com/Alexays/Waybar/wiki/Examples)
*   [Dotfiles Repositories](https://github.com/topics/waybar-config)
*   [Reddit /r/unixporn](https://www.reddit.com/r/unixporn/)

### "Copy-Paste" Workflow

1.  **Find a theme you like.** It will usually consist of a `config` (JSON) and a `style.css`.
2.  **Copy the JSON** content into `hosts/default/waybar/config.jsonc`.
3.  **Copy the CSS** content into `hosts/default/waybar/style.css`.
4.  **Apply the changes:**
    ```bash
    sudo nixos-rebuild switch --flake .#default
    ```
    *(Or `home-manager switch` if you are using standalone Home Manager)*

## Current Theme: Gruvbox Dark

The current default theme is **Gruvbox Dark**.

*   **Background:** Dark Grey/Brown (`#282828`)
*   **Modules:** Individual "cards" with colored bottom borders.
*   **Colors:** Earthy tones (Red, Green, Yellow, Blue, Aqua).

## Troubleshooting

### "Empty White Blocks"
If you see empty blocks on the bar, it usually means a module is enabled in `config.jsonc` but has no data to show, and the `style.css` is giving it padding/margin.

**Fix:** Ensure your CSS handles empty states (e.g., `window#waybar.empty #window { background: transparent; }`) or check the module's format settings in the JSON config.

### Icons missing
If icons (like wifi, battery, volume) appear as weird rectangles, you are missing a Nerd Font.
Ensure `programs.stylix.fonts` includes a Nerd Font (e.g., `JetBrainsMono Nerd Font`).
