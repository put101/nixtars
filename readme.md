
# Commands: 

```sh
sudo nixos-rebuild switch --flake /home/tobi/#nixtars
```


# Issues and TODOs

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


