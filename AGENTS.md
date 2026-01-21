# Repository Guidelines

## Project Structure & Module Organization
`flake.nix` is the single entry point; it pins `nixos-unstable`, wires in `home-manager`, `nvf`, `stylix`, and exports the `nixtars` configuration. Host-specific logic lives under `hosts/default/` with `configuration.nix` for system services, `home.nix` for the user profile, `nvf.nix` for Neovim, and `waybar/` plus `config.kdl` for UI tweaks. Keep shared assets (e.g., `wallpaper.png`, VPN material in `secrets/`) in place because their paths are referenced directly inside those modules.

## Build, Test, and Development Commands
- `./build.sh` or `nixos-rebuild switch --flake .#nixtars` applies the full system profile. Run it after any Nix module edit.
- `nixos-rebuild dry-activate --flake .#nixtars` validates evaluation without touching the system, ideal for CI-style checks.
- `nixos-rebuild test --flake .#nixtars` boots the new generation in a transient session; use it before risky hardware or display tweaks.
- `home-manager switch --flake .#nixtars` replays just the Home Manager layer when touching `home.nix`, `nvf.nix`, or `waybar/`.

## Coding Style & Naming Conventions
Stick to two-space indentation in `.nix` files, align attribute assignments, and keep option blocks grouped logically (see `hosts/default/configuration.nix`). Derivations and module names stay lowercase with hyphen-separated words (`stylix.nix`, `home.nix`). Prefer helper functions from `lib` for overrides (`lib.mkForce`, `lib.mkDefault`). Run `nix fmt` or `nixpkgs-fmt` before committing, and keep KDL/CSS files wrapped at roughly 100 columns.

## Testing Guidelines
There is no automated test suite; validation happens through Nix builds. Always run `nixos-rebuild dry-activate` before `switch` to catch evaluation errors early, and add `--show-trace` when diagnosing module failures. For graphical configs (`hosts/default/config.kdl`, `waybar/style.css`), launch `niri` or `waybar` under a nested session (`dbus-run-session niri --config hosts/default/config.kdl`) to verify bindings without impacting the main seat.

## Commit & Pull Request Guidelines
Recent history (`git log`) favors short, lowercase, imperative subject lines (“niri”, “added nvf, codex”). Follow that style, scope commits narrowly, and reference affected modules in the subject if possible (`waybar: adjust battery widget`). Pull requests should include a short summary, the command output used for validation (e.g., `nixos-rebuild test`), linked issues or TODO references, and screenshots for UI adjustments.

## Security & Secrets
Files under `secrets/` (VPN env and certificates) are referenced by commented service stanzas. Never commit real credentials; replace them with sample placeholders or keep them untracked via `git update-index --skip-worktree`. When sharing logs, scrub hostnames, session sockets, and `niri` paths to avoid leaking environment details.

## NVF Troubleshooting Notes
The NVF profile mirrors the upstream maximal template (`hosts/default/nvf.nix`) and writes persistent Neovim logs to `~/.local/state/nvf/nvim.log` plus per-plugin logs (e.g., `luasnip.log`, `nio.log`). A custom `vim.notify` shim sends every warning/error into `~/.local/state/nvf/notify.log`, which appears after the first notification is emitted. To capture issues, reproduce them, then run `tail -F ~/.local/state/nvf/{nvim,notify}.log` and attach the resulting files. If `nvim-treesitter` errors mention missing `ts_utils`, ensure `vim.treesitter.enable = true` stayed in the config; disabling it removes the plugin and breaks dependent modules.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
