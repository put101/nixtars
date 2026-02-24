# Commands: 

```sh
sudo nixos-rebuild switch --flake /home/tobi/#nixtars
```

## Hugging Face

Non-interactive Hugging Face auth (works in both KDE and Niri):

- `docs/HUGGINGFACE_AUTH.md`

## Customization

- [Waybar Theming & Configuration](docs/WAYBAR_THEMING.md) - How to change the status bar look and feel.

### Wallpaper

Ongoing issue when updating downloads full 1GB repo each time.
```sh
[tobi@nixtars:~/nixtars]$ nix flake update
[225.6/0.0 MiB DL] downloading 'https://github.com/AngelJumbo/gruvbox-wallpapers/archive/46c4
```
# Issues and TODOs

- 
  Summary of Findings:
   1. Niri Config Error: You have a syntax error in ~/nixtars/hosts/default/config.kdl on
      line 319 (Mod+? is missing an action block).
   2. Networking & Signal Issues: Your Niri session lacks a running Secret Service (Keyring).
      KDE Plasma provides this automatically (kwallet), but Niri does not. This prevents
      NetworkManager from saving Wi-Fi passwords and Signal from accessing its encryption
      keys.
   3. Reference Comparison: Your friend 'not-matthias' explicitly enables gnome-keyring and
      polkit in their Niri module, which is missing from your configuration.

  Proposed Plan:
   1. Fix Niri Config: Remove the broken line in config.kdl.
   2. Enable Keyring: Add services.gnome.gnome-keyring.enable = true; to your
      configuration.nix to handle passwords and secrets system-wide.
      


- [tobi@nixtars:~]$ niri
2026-01-15T15:15:14.296571Z  INFO niri: starting version 25.11 (Nixpkgs)
2026-01-15T15:15:14.353075Z  WARN niri:   × error loading config
  ├─▶ error parsing
  ╰─▶ error parsing KDL

Error:   × invalid keybind
  ├─▶ invalid keybind
  ╰─▶ invalid key: ?
     ╭─[config.kdl:362:1]
 362 │     Mod+Shift+Slash { show-hotkey-overlay; }
 363 │     Mod+?
     ·     ──┬──
     ·       ╰── invalid value
 364 │
     ╰────

2026-01-15T15:15:14.455333Z  WARN niri::backend::winit: error binding renderer wl_display: None of the following EGL extensions is supported by the underlying EGL implementation, at least one is required: ["EGL_WL_bind_wayland_display"]
2026-01-15T15:15:14.476626Z DEBUG niri::niri: putting output winit at x=0 y=0
2026-01-15T15:15:14.476672Z  INFO niri: listening on Wayland socket: wayland-2
2026-01-15T15:15:14.476676Z  INFO niri: IPC listening on: /run/user/1000/niri.wayland-2.42094.sock
2026-01-15T15:15:14.479010Z  INFO niri: listening on X11 socket: :1
2026-01-15T15:15:19.189412Z DEBUG niri::utils::watcher: exiting watcher thread for Regular { user_path: "/home/tobi/.config/niri/config.kdl", system_path: "/etc/niri/config.kdl" }

## [Fixed] Ralph TUI Configuration Persistence Issue (2026-01-21)

### Symptom
The `ralph-tui` CLI was unable to find the project configuration (`.ralph-tui/config.toml`) even after running the `setup` command successfully multiple times.
Output of `ralph-tui config show` consistently showed:
```
│ Project config:
│   ○ .ralph-tui/config.toml (not found in project tree)
```

### Investigation
1.  **Behavior Analysis:** The application seemed to be looking in the wrong place or ignoring the current working directory.
2.  **Codebase Inspection:**
    *   Cloned `https://github.com/subsy/ralph-tui` to `~/repos/ralph-tui`.
    *   `src/config/index.ts`: Verified that config loading relies on `process.cwd()` to find the project root.
    *   `src/sound.ts`: Verified that asset loading uses `import.meta.url` (relative to the script file), meaning it does *not* require the process CWD to be the installation directory.
3.  **Package Definition Check (`pkgs/ralph-tui.nix`):**
    *   Found the following `makeWrapper` command:
        ```nix
        makeWrapper "${lib.getExe bun}" "$out/bin/ralph-tui"
          --chdir "$out/lib/ralph-tui"  # <--- THE CULPRIT
          --add-flags "$out/lib/ralph-tui/dist/cli.js"
        ```

### Root Cause
The `pkgs/ralph-tui.nix` derivation included a `--chdir "$out/lib/ralph-tui"` flag in the wrapper script. This forced the application to switch its working directory to the immutable Nix store path immediately upon launch. Consequently, `process.cwd()` returned the store path instead of the user's project directory, causing the configuration lookup to fail.

### Fix
Removed the `--chdir` flag from `pkgs/ralph-tui.nix`.
**File:** `pkgs/ralph-tui.nix`
```diff
-      --chdir "$out/lib/ralph-tui" \
```

### Verification
After rebuilding (`sudo nixos-rebuild switch --flake .#nixtars`), `ralph-tui` now correctly respects the user's working directory and can locate the `.ralph-tui/config.toml` file.

## [Fixed] OpenCode Agent Hanging (2026-01-21)

### Symptom
After fixing the configuration issue, `ralph-tui create-prd` using the `opencode` agent would appear to hang ("it didn't do anything") after the user entered input.

### Investigation
1.  Verified `ralph-tui doctor` passed and `opencode run "hello"` worked interactively, confirming the underlying agent was functional.
2.  Analyzed `OpenCodeAgentPlugin.ts` and discovered that the output parser was splitting incoming data chunks by newline characters without buffering.
3.  Hypothesis: `opencode` (or the shell pipe) was delivering JSON output in partial chunks (e.g., split across two buffers). The existing logic attempted to parse each chunk individually, failing on partial JSON, causing the data to be discarded silently.

### Root Cause
Missing line buffering in `OpenCodeAgentPlugin.ts`. If an incoming data chunk did not end perfectly on a newline, or if a JSON object was split across chunks, the partial data was lost, resulting in no response being displayed in the TUI.

### Fix
Implemented a buffer in `OpenCodeAgentPlugin.ts` to accumulate incoming data and only process complete lines (terminated by `\n`).

**File:** `pkgs/ralph-tui.nix` (Updated to apply patch)
```nix
  configurePhase = ''
    # ...
    cp ${./patched/opencode.ts} src/plugins/agents/builtin/opencode.ts
    # ...
  '';
```

**File:** `pkgs/patched/opencode.ts` (New file)
```typescript
// Added buffering logic to execute method
buffer += data;
if (!buffer.includes('\n')) return;
const lines = buffer.split('\n');
buffer = lines.pop() ?? ''; 
// ... process complete lines ...
```

### Verification
Rebuilt the system with the patch. `ralph-tui doctor` continues to pass, and the buffering logic ensures reliable communication with the `opencode` agent.

## Architectural Patterns (BP2)

As of February 2026, the project follows these architectural patterns:

- **State Separation:** System configuration (Nix) is separated from volatile application state.
- **Archive & Rehydrate:** Long-term data is archived and rehydrated into the environment to maintain reproducibility.
- **Documentation First:** All significant architectural changes are documented in `docs/` and reflected here.

## [Fixed] sum-astro-nvim Build Failure (2026-02-20)

### Symptom
Build failing with 404 errors when fetching `sum-astro-nvim` and missing attribute `nixpkgs-unstable`.

### Investigation
1. `SumAstroNvim` repository changed its default branch structure or the URL in `flake.nix` was pointing to a non-existent `main` branch (fixed by using `master`).
2. The `sumAstroNvim` Nix module expects `nixpkgs-unstable` to be passed as a top-level argument via `specialArgs`.
3. `sumAstroNvim.nerdfont` option requires a package type, but was being passed a string `"JetBrainsMono"`.

### Fix
1. **Flake URL:** Kept `sum-astro-nvim.url` as `github:sum-rock/SumAstroNvim/master`.
2. **Special Args:** Updated `flake.nix` to explicitly inherit `nixpkgs-unstable` into `specialArgs`.
   ```nix
   specialArgs = {
     inherit inputs;
     inherit (inputs) nixpkgs-unstable;
   };
   ```
3. **Font Config:** Updated `hosts/default/configuration.nix` to use `pkgs.nerd-fonts.jetbrains-mono`.
   ```nix
   nerdfont = pkgs.nerd-fonts.jetbrains-mono;
   ```

### Verification
`sudo nixos-rebuild switch --flake .#nixtars` completed successfully.
