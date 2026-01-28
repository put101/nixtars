# agenix in nixtars

This repo uses `agenix` (age-encrypted secrets) so secrets can be stored in git
as encrypted `*.age` files and decrypted automatically at activation time.

The goal is:

- no plaintext credentials committed to git
- secrets survive “clone repo on a new machine” (given you have the decryption key)
- Nix configs refer to secrets via `config.age.secrets.<name>.path`

This document also explains the pre-agenix state, because a lot of tooling (HF,
PIA) originally relied on local plaintext files.

## Where we came from (pre-agenix)

### Hugging Face CLI state
`hf auth login` stores tokens locally in your home directory:

- active token: `~/.cache/huggingface/token`
- stored tokens: `~/.cache/huggingface/stored_tokens`

This is machine-local state (not in git; not reproducible by `nixos-rebuild`).

### nixtars plaintext secrets pattern
Historically, this repo used a local untracked directory for secrets:

- `.gitignore` ignored `secrets/`
- you placed plaintext files like:
  - `secrets/huggingface.token`
  - `secrets/pia.env`

Then Home Manager activation/scripts read those plaintext files.

In particular, `hosts/default/home.nix` had an activation step that:

- read the token from `secrets/huggingface.token`
- wrote it to `~/.cache/huggingface/token` (what `hf download ...` reads)
- optionally seeded `git-credential-manager` for `huggingface.co`

This worked, but:

- plaintext tokens lived on disk
- onboarding a new machine required manually recreating plaintext files
- the repo couldn’t carry encrypted secrets because `secrets/` was fully ignored

## What we have now (agenix)

### Repo-level changes

- `flake.nix` includes `agenix` as an input and enables `inputs.agenix.nixosModules.default`.
- `hosts/default/configuration.nix` imports `hosts/default/agenix.nix`.
- `hosts/default/agenix.nix` sets the default decrypt identity:
  - `age.identityPaths = [ "/home/tobi/.config/agenix/keys.txt" ]` (overrideable)
- `.gitignore` now tracks encrypted secrets and the mapping file:
  - tracked: `secrets/secrets.nix`, `secrets/*.age`
  - ignored: any other plaintext under `secrets/`

### agenix rules file location

The `agenix` CLI expects recipient rules at `./secrets.nix` by default.

This repo keeps the main mapping at `secrets/secrets.nix`, and provides a
wrapper at `secrets.nix` so the following works without extra flags:

```sh
agenix -e secrets/huggingface.token.age
```

### Secrets layout

- Encrypted secrets live in-repo:
  - `secrets/huggingface.token.age`
  - `secrets/pia.env.age`
  - any future secret: `secrets/<name>.age`

- Recipients and which secrets they can decrypt:
  - `secrets/secrets.nix`

### How secrets are used at runtime

Home Manager declares secrets (only if the `.age` file exists):

- `huggingface-token` -> `secrets/huggingface.token.age`
- `pia-env` -> `secrets/pia.env.age`

Then config uses the decrypted paths:

- HF: activation reads `config.age.secrets."huggingface-token".path`
  and writes to `~/.cache/huggingface/token`.
- PIA: `pia-run` sources `config.age.secrets."pia-env".path`.

For compatibility while migrating, both flows also support a fallback:

- HF fallback: `/home/tobi/nixtars/secrets/huggingface.token`
- PIA fallback: `/home/tobi/nixtars/secrets/pia.env`

Once you have encrypted secrets working, you can delete the plaintext fallback
files and just keep the `.age` files.

## Setup / migration steps

### 1) Add your recipient key(s)

Edit `secrets/secrets.nix` and replace the placeholder public key with your
real one.

This repo defaults to a dedicated age key. Generate one and copy the public key
into `secrets/secrets.nix`.

Generate (preferred, once `age` is installed):

```sh
mkdir -p ~/.config/agenix
age-keygen -o ~/.config/agenix/keys.txt
```

If `age-keygen` is not on PATH yet:

```sh
mkdir -p ~/.config/agenix
nix shell nixpkgs#age -c age-keygen -o ~/.config/agenix/keys.txt
```

Print public key:

```sh
age-keygen -y ~/.config/agenix/keys.txt
```

### 2) Create or edit encrypted secrets

Create the `.age` files (or update them):

```sh
RULES=./secrets.nix agenix -e secrets/huggingface.token.age
RULES=./secrets.nix agenix -e secrets/pia.env.age
```

If `agenix` is not available yet:

```sh
nix run github:ryantm/agenix -- -e secrets/huggingface.token.age
nix run github:ryantm/agenix -- -e secrets/pia.env.age
```

Secret contents guidelines:

- `secrets/huggingface.token.age`: token string only (no extra whitespace)
- `secrets/pia.env.age`: env file lines (same format you used previously)

### 3) Rebuild

```sh
sudo nixos-rebuild switch --flake .#nixtars
```

### 4) Verify

```sh
hf auth whoami
hf download google/gemma-3n-E2B-it --max-workers 1
```

PIA:

```sh
pia-list
```

## Important note: flakes only see tracked files

New files must be `git add`'d (staged) or committed before `nixos-rebuild` will
see them. This is a flake behavior, not an agenix behavior.

If you add a new `*.age` file and Nix can’t find it, run:

```sh
git add secrets/<name>.age
```

## New machine bootstrap

To decrypt secrets on a fresh machine, you need:

1) the repo (including `secrets/*.age` + `secrets/secrets.nix`)
2) the private key matching one of the recipients

By default this config expects the private age key at:

- `/home/tobi/.config/agenix/keys.txt`

Once the key exists on the machine:

```sh
sudo nixos-rebuild switch --flake .#nixtars
```

and secrets will be decrypted automatically.

## Adding secrets for future tools (the standard pattern)

1) Create `secrets/<thing>.age`
2) Add it to `secrets/secrets.nix` (public keys recipients)
3) In Nix, reference it as:

- NixOS services: `config.age.secrets.<thing>.path`
- Home Manager scripts/programs: `config.age.secrets.<thing>.path`

Examples of tools that usually benefit:

- API tokens: OpenAI/Anthropic, Hugging Face, GitHub automation tokens
- VPN material: env files, certs/keys
- backups: restic passwords + cloud env
- any service config that needs secrets (DB passwords, JWT secrets, OAuth client secrets)

## Troubleshooting

### "Cannot decrypt" / missing identity
Verify the private key exists at the configured identity path and matches one of
the recipients.

### Hugging Face still prompts / 403

- Confirm HF CLI sees your token file:
  - `ls -l ~/.cache/huggingface/token`
- Confirm the token is for the account that actually has access:
  - `hf auth whoami`
