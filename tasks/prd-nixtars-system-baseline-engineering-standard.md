# PRD: Nixtars System Baseline & Engineering Standard

## 1. Overview
This document defines the architectural baseline, engineering principles, and functional requirements for the `nixtars` NixOS configuration. This repository serves as a monolithic Infrastructure-as-Code (IaC) source of truth for the `nixtars` host, ensuring a reproducible, immutable, and modular computing environment. It unifies system-level configuration (NixOS), user-level environment (Home Manager), application configuration (NVF, Waybar), and secrets management into a single cohesive dependency graph rooted in `flake.nix`.

## 2. Core Engineering Principles
The development and maintenance of this system adhere to the following 20 principles, combining NixOS philosophy with modern software engineering best practices:

### NixOS Fundamentals
1.  **Strict Declarativity:** Define *what* the system state should be, not the imperative steps to achieve it.
2.  **Total Reproducibility:** Identical inputs (`flake.nix` + `flake.lock`) must yield bit-for-bit identical system closures.
3.  **Immutability:** The running system state is read-only; changes are applied atomically via new generations.
4.  **Atomic Upgrades:** System transitions are transactional. If a build fails, the system state remains untouched.
5.  **Hermetic Isolation:** Dependencies are encapsulated per-package in the Nix store, preventing conflicts ("dependency hell").
6.  **Single Source of Truth:** `flake.nix` is the absolute root of the dependency graph. No external side-effects allowed.
7.  **Fail Fast:** Prefer build-time evaluation errors over runtime failures. Validate configurations during `dry-activate`.
8.  **Ephemeral State:** Treat the root filesystem as volatile where possible; persistent state is explicitly curated.
9.  **Pinning & Locking:** All upstream inputs are version-pinned via `flake.lock` to prevent "works on my machine" drift.
10. **Idempotency:** Re-applying the current configuration must result in a zero-change operation.

### General Engineering & Architecture
11. **Separation of Concerns:** Strict boundaries between Hardware (`hardware-configuration.nix`), System (`configuration.nix`), and User (`home.nix`).
12. **Modularity:** Logical grouping of functionality into dedicated modules (e.g., `nvf.nix`, `stylix.nix`, `waybar/`).
13. **DRY (Don't Repeat Yourself):** Utilize `lib.mkDefault`, `lib.mkForce`, and shared logic to minimize code duplication.
14. **Least Privilege:** Secrets are referenced safely, never committed to git, and permissions are scoped tightly (e.g., `trusted-users`).
15. **Convention over Configuration:** Adhere to the established directory structure (`hosts/`, `pkgs/`, `secrets/`) for predictable navigation.
16. **Explicit Dependency Injection:** Pass `inputs`, `pkgs`, and `lib` explicitly to modules; avoid global state.
17. **Continuous Validation:** Treat local builds (`nixos-rebuild`) as a CI pipeline. Code that doesn't build doesn't exist.
18. **Code as Documentation:** Write self-documenting Nix expressions. Comments explain *why*, not *what*.
19. **Standardized Formatting:** Enforce consistent style (2-space indent, attribute alignment) via `nix fmt`.
20. **Auditability:** Every system state change is inextricably linked to a Git commit hash.

## 3. System Architecture & Scope

### 3.1 Scope Hierarchy
The system is composed of the following layers:
*   **Root:** `flake.nix` (Entry point, inputs, outputs).
*   **Host Layer:** `hosts/default/` (Machine-specific config).
    *   **System:** `configuration.nix` (Boot, Network, Services, Virtualization).
    *   **Hardware:** `hardware-configuration.nix` (Filesystems, Kernel modules).
*   **User Layer:** `home.nix` (Home Manager: Shells, Git, UI themes).
    *   **Applications:** `nvf.nix` (Neovim), `waybar/` (Status bar), `config.kdl` (Niri WM).
*   **Assets & Secrets:** `secrets/` (VPN, Certs). Wallpapers managed via `gruvbox-wallpapers` flake and `wpaperd`.
*   **Custom Packages:** `pkgs/` (Patched binaries, scripts).

### 3.2 Key Components
*   **OS:** NixOS Unstable.
*   **Window Manager:** Niri (Scrollable Tiling Wayland Compositor) & KDE Plasma 6.
*   **Editor:** Neovim (configured via NVF).
*   **Shell:** Fish (with plugins).
*   **Styling:** Stylix (Global theme management).
*   **AI Orchestration:** Ralph TUI & Ralph Orchestrator.

## 4. Quality Gates

All changes to the repository must pass the following checks before being considered "Complete":

1.  **Format Compliance:**
    ```bash
    nix fmt --check
    ```
2.  **Evaluation Safety (Dry Run):**
    ```bash
    nixos-rebuild dry-activate --flake .#nixtars --show-trace
    ```
3.  **System Integrity (VM Test):**
    ```bash
    nixos-rebuild test --flake .#nixtars
    ```
4.  **Git Hygiene:**
    *   Commit messages must follow the imperative style (e.g., "waybar: fix battery module").
    *   No secrets in `git status`.

## 5. User Stories & Functional Requirements

### US-001: Maintain Reproducible System State
**Description:** As a System Administrator, I want the system to be fully reproducible from git so that I can recover or replicate the environment instantly.
**Acceptance Criteria:**
- [ ] `flake.lock` is up to date.
- [ ] Fresh clone + `nixos-rebuild build` yields a successful result.
- [ ] No unmanaged imperative packages (e.g., `nix-env -i`) are required.

### US-002: Modular Application Configuration
**Description:** As a Developer, I want complex applications like Neovim and Waybar to have isolated configuration files so that `configuration.nix` remains clean.
**Acceptance Criteria:**
- [ ] Neovim config resides strictly in `nvf.nix` (or `hosts/default/nvf.nix`).
- [ ] Waybar config resides in `hosts/default/waybar/`.
- [ ] Changes to these modules trigger Home Manager activations correctly.

### US-003: Secure Secret Management
**Description:** As a User, I want to use VPNs and private services without exposing credentials in the public repo.
**Acceptance Criteria:**
- [ ] Secrets (certs, env files) are ignored by git (`.gitignore` or `skip-worktree`).
- [ ] System services reference secrets via absolute paths to the `secrets/` directory.
- [ ] Placeholder files or documentation exist to explain required secrets.

### US-004: Robust Update Mechanism
**Description:** As a User, I want to update system packages and inputs safely.
**Acceptance Criteria:**
- [ ] `nix flake update` updates lockfile.
- [ ] `build.sh` (or rebuild alias) applies changes successfully.
- [ ] Bootloader entries are preserved for rollback.

## 6. Non-Goals
*   **Imperative Package Management:** The use of `nix-env` or `nix profile install` is strictly discouraged.
*   **Universal Compatibility:** This config is tuned specifically for the `nixtars` host hardware and user workflows; generic portability is secondary.
*   **GUI Configuration:** Settings should be defined in code (Nix/KDL/CSS), not changed via GUI settings menus where possible.

## 7. Success Metrics
*   **Build Time:** Evaluation and build time remains within acceptable limits (avoiding excessive recompilation).
*   **Stability:** Zero build failures on the `main` branch.
*   **Cleanliness:** `nix fmt` produces no diffs.