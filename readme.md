
# Commands: 

```sh
sudo nixos-rebuild switch --flake /home/tobi/#nixtars
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


