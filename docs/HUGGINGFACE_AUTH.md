# Hugging Face: Non-Interactive Auth (git + git-lfs + hf)

This repo configures Hugging Face authentication so that downloading/cloning models works in **both KDE Plasma and Niri** (no GUI askpass prompts, no manual `hf auth login`).

It does this by keeping the token in a local file under `~/nixtars/secrets/` (gitignored) and, on each rebuild, seeding both:

- the Hugging Face CLI token file (`~/.cache/huggingface/token`)
- git credentials via `git-credential-manager` into your system keyring (Secret Service)

## What you need to do

1) Put your token (single line) here:

- `/home/tobi/nixtars/secrets/huggingface.token`

The file currently exists with a placeholder. Replace the placeholder with your real token, e.g.

```
hf_1234567890abcdef...
```

2) Apply the config:

```bash
sudo nixos-rebuild switch --flake /home/tobi/nixtars#nixtars
```

After that, `git` / `git-lfs` / `hf` will authenticate without prompting.

## What happens on rebuild

During the rebuild, Home Manager runs an **activation step**:

- Config location: `/home/tobi/nixtars/hosts/default/home.nix`
- Activation entry name: `home.activation.huggingfaceAuth`

On activation, if the token file exists, it performs these actions:

1) Reads the token from:
- `/home/tobi/nixtars/secrets/huggingface.token`

2) Writes Hugging Face CLI / Python token file:
- `~/.cache/huggingface/token`

This is what the `huggingface_hub` library (and the `hf` / `huggingface-cli` commands) use for authentication.

3) Stores Git HTTPS credentials for Hugging Face in the system keyring via `git-credential-manager`.

Git then uses this automatically (via `credential.helper`) for:

- `git clone https://huggingface.co/<org>/<repo>`
- `git lfs pull` and other LFS downloads (which are usually HTTPS-authenticated)

4) Ensures `git-lfs` is initialized for your user:

- Runs `git lfs install --skip-repo` (safe to run repeatedly)

5) Sets file permissions:

- `~/.cache/huggingface/token`: `0600`

Because this is done during activation, it works the same whether you log in via KDE or Niri.

## What was changed in this repo

All changes are in:

- `/home/tobi/nixtars/hosts/default/home.nix`

Specifically:

- Added `home.activation.huggingfaceAuth` to copy the token into the right runtime locations.
- Enabled git credential storage:
  - `credential.helper = ".../git-credential-manager"`
  - `credential.useHttpPath = true`
- Added packages:
  - `git-lfs`
  - `git-credential-manager`
  - `python3Packages.huggingface-hub`

And created:

- `/home/tobi/nixtars/secrets/huggingface.token`

Your `secrets/` directory is already gitignored (see `/home/tobi/nixtars/.gitignore`).

## How to use (common workflows)

### Clone a model repo without downloading weights immediately

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/HuggingFaceTB/SmolM2-1.7B-Instruct
```

Then download LFS files later:

```bash
cd SmolM2-1.7B-Instruct
git lfs pull
```

### Download a single file (no git repo)

This uses the installed `hf` CLI.

```bash
hf download HuggingFaceTB/SmolM2-1.7B-Instruct --include "*.safetensors" --local-dir ./SmolM2
```

## Notes / gotchas

### Keyring (Secret Service)

This setup relies on a Secret Service provider:

- In KDE Plasma: provided by KWallet
- In Niri (or other non-Plasma sessions): provided by `gnome-keyring`

This repo enables `gnome-keyring` and hooks it into PAM so it unlocks on login (see `/home/tobi/nixtars/hosts/default/configuration.nix`).

### Gated models

If a repo is gated, you still must accept access on the model page once ("Agree" / "Request access"). A token cannot bypass that.

### Security trade-off

Git credentials are stored in the system keyring (Secret Service), which is the "proper" setup.

The token source file (`/home/tobi/nixtars/secrets/huggingface.token`) is still plain text on disk (gitignored) and is used only to seed the keyring automatically on rebuild.

## Rotating the token

1) Edit:
- `/home/tobi/nixtars/secrets/huggingface.token`

2) Rebuild:

```bash
sudo nixos-rebuild switch --flake /home/tobi/nixtars#nixtars
```

The rebuild rewrites `~/.cache/huggingface/token` with the new token.

The rebuild also updates the Hugging Face entry in your keyring via `git-credential-manager`.

## Troubleshooting

- If `git` still prompts: check `git config --get credential.helper` and ensure `git-credential-manager` is installed.
- If LFS downloads fail: run `git lfs env` and `git lfs pull` inside the repo to see the real error.
- If you see askpass errors again: you can force terminal prompting for one command with:

```bash
env -u GIT_ASKPASS -u SSH_ASKPASS -u SSH_ASKPASS_REQUIRE GIT_TERMINAL_PROMPT=1 <your-git-command>
```
