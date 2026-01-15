# Session Diagnosis: Niri & NixOS Setup

## 1. Niri Configuration Error (Fixed)
**Issue:** `niri` command reported errors due to syntax error in config.
**Fix:** Removed dangling `Mod+?` in `config.kdl`.
**Status:** **Applied**.

## 2. Networking & Wallet Issues (Fixed)
**Issue:** Wi-Fi forgot passwords, Signal crashed.
**Fix:** Enabled `gnome-keyring` and `polkit` in `configuration.nix`.
**Status:** **Applied**.

## 3. Visual Overhaul (In Progress)
**Objective:** Replace default "blocky" look with a "Pro" Catppuccin-themed setup (Stylix + Custom Waybar).

### Action Log
1.  **Global Theming (Stylix):**
    *   **Created:** `nixtars/hosts/default/stylix.nix`
        *   **Scheme:** Catppuccin Mocha (Dark).
        *   **Wallpaper:** `nixtars/wallpaper.png` (Forest Landscape).
        *   **Fonts:** JetBrains Mono (Mono) & DejaVu Sans (UI).
    *   **Modified:** `nixtars/hosts/default/configuration.nix`
        *   Imported `./stylix.nix`.
        *   Added `inputs.stylix.nixosModules.stylix` to imports.

2.  **Custom Waybar:**
    *   **Created:** `nixtars/hosts/default/waybar/default.nix` & `style.css`.
        *   **Style:** Transparent background, floating pill-shaped modules, Catppuccin colors.
        *   **Modules:** Niri Workspaces, Clock, PulseAudio, Network, Battery, Tray.
    *   **Modified:** `nixtars/hosts/default/home.nix`
        *   Removed simple `programs.waybar.enable = true`.
        *   Imported `./waybar/default.nix`.

### Next Steps for User
To apply these visual changes:
1.  Run the build script:
    ```bash
    cd ~/nixtars
    ./build.sh
    ```
2.  Log out and log back in to see the new theme, wallpaper, and Waybar.

## 4. Signal & Keyring Backend Mismatch (Fixed?)

**Symptom:** Signal crashes immediately on startup.
**Root Cause:** Niri session was not updating the DBus/Systemd environment, so `gnome-keyring` (and other user services) didn't know how to communicate with the session.

**Fix Applied (Session 2):**
1.  **Niri Autostart:** Added `dbus-update-activation-environment` and `systemctl --user import-environment` to `config.kdl` to properly initialize the session for services like `gnome-keyring`.
2.  **System Tray:** Added `networkmanagerapplet` (nm-applet) to `home.nix` and `config.kdl` to provide the Wi-Fi tray icon.
3.  **Clipboard/Screenshots:** Added `wl-clipboard` and `slurp` to `home.nix`.

**Status:** **Applied**. Waiting for rebuild and re-login to verify.

**What We Have Done (System Level):**
*   Updated `configuration.nix` to include proper `xdg-desktop-portal` configuration (wlr, gtk, gnome) to ensure standard secret service communication works in Wayland.
*   Explicitly enabled `gnome-keyring` integration in PAM and Polkit.
*   Added `libsecret` and `signal-desktop` (explicitly) to system packages.

## 5. Next Steps
1.  **Build:** Run `./build.sh` to apply all changes.
2.  **Re-login:** Exit Niri and start it again.
3.  **Verify:**
    *   Check if `nm-applet` appears in the tray (top right).
    *   Check if Signal starts without crashing.
    *   Check if `Print` key takes a screenshot (check `~/Pictures/Screenshots`).

## 6. Python REPL in Neovim (NVF)
**Objective:** Enable `iron.nvim` for Python interactive development.
**Action:**
*   Created `nixtars/hosts/default/nvf.nix`.
*   Enabled `languages.python` (LSP, Formatting, Treesitter).
*   Added `iron.nvim` to `startPlugins`.
*   Configured `iron.nvim` with:
    *   **Command:** `python3` (from Nix store).
    *   **Layout:** Bottom split (40%).
    *   **Keymaps:**
        *   `<Space>sl`: Send Line
        *   `<Space>sf`: Send File
        *   `<Space>sc`: Send Selection/Motion