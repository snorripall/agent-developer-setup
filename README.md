# My Dotfiles

Personal configuration for Linux (CachyOS + niri) and macOS. It will change over time based on needs and preferences.

This can be a starting point for your own setup. Use at your own risk.

If you wish to contribute improvements (agents, skills, etc.), open a pull request and explain the problem you are solving.

## Layout

```text
dotfiles/
├── fish/                      # OS-agnostic shell config
│   ├── config.fish
│   ├── conf.d/                # shared snippets (abbreviations, …)
│   └── functions/             # e.g. env-sync
├── zed/                       # shared Zed settings
├── opencode/                  # shared OpenCode config
│   ├── opencode.json          # base (plugin, permissions, MCPs)
│   ├── AGENTS.md
│   └── profiles/
│       ├── cloud.json         # API models (Kimi, etc.)
│       └── homelab.json       # local/homelab models
├── os/
│   ├── linux/                 # CachyOS / niri machine only
│   │   ├── fish/conf.d/       # CachyOS source, keychain, SUDO_ASKPASS
│   │   ├── niri/
│   │   ├── bin/sudo-askpass
│   │   ├── opencode/          # OS overlay (Chromium path for Playwright)
│   │   ├── skills/
│   │   └── setup/             # one-shot helpers (ssh, niri)
│   └── macos/                 # macOS only
│       ├── fish/conf.d/
│       ├── zed/keymap.json    # cmd- bindings
│       └── opencode/          # OS overlay
└── scripts/
    ├── bootstrap.sh           # install shared + OS pack
    └── opencode-profile.sh    # switch cloud | homelab agents
```

**Mental model**

| Layer | Meaning | Examples |
|--------|---------|----------|
| Repo-root tools (`fish/`, `zed/`, `opencode/`) | Same on every machine | abbreviations, env-sync, Zed theme, AGENTS.md |
| `os/<platform>/` | How this OS reaches the world | niri, sudo-askpass, Chromium path, `cmd` keymaps |
| `opencode/profiles/` | Which models to use (role, not OS) | cloud vs homelab |

## Quick start

```bash
git clone <this-repo> ~/Code/dotfiles   # any path is fine
cd ~/Code/dotfiles
./scripts/bootstrap.sh                  # detects Linux vs macOS
./scripts/bootstrap.sh --profile cloud  # or: homelab
```

Dry-run:

```bash
./scripts/bootstrap.sh --dry-run
```

Force an OS pack (e.g. testing):

```bash
./scripts/bootstrap.sh --os linux
./scripts/bootstrap.sh --os macos
```

Switch agent profile later without re-linking everything:

```bash
./scripts/opencode-profile.sh cloud
./scripts/opencode-profile.sh homelab
./scripts/opencode-profile.sh          # show current
```

Bootstrap will:

- Symlink shared `fish`, `zed`, and OS packs into `~/.config/…` (and `~/.local/bin` for Linux helpers)
- Merge `opencode/opencode.json` + `os/<platform>/opencode/opencode.overlay.json` → `~/.config/opencode/opencode.json` (requires `jq`)
- Symlink the chosen profile to `~/.config/opencode/oh-my-openagent.json`
- Back up real files once if they are not already symlinks

### Linux extras

```bash
./os/linux/setup/niri.sh   # niri only (also covered by bootstrap)
./os/linux/setup/ssh.sh    # interactive SSH + KWallet setup (CachyOS)
```

Ensure Niri loads the custom file:

```kdl
// in ~/.config/niri/config.kdl
include "custom.kdl"
```

## Criteria

Target environment (not all criteria met yet):

### All tools

- Runs on Linux and macOS
  - Linux: CachyOS + niri + Dank Material Shell
  - macOS: Apple Silicon
- Open source
- Bring your own API keys (no model lock-in)

### Editor

- Super fast, large files, extensible
- Native tools via ACP; 3rd-party AI agents
- Agent protocols: ACP (done), A2A (goal)
- Git support

### Agent harness

- Custom models and routing
- Robust permissions
- Custom agents and skills
- ACP / A2A so it can run inside a compatible editor
- CLI for autonomous runs and server work
- Planning: rewrite prompts, break down tasks, epics/branches, dependency order

## Workflow

Most time is spent planning features and writing detailed requirements.

1. **Ideation** — Structure the idea with a general agent; keep it architecture/product level, not tech choice. Summarize for planning.
2. **Planning** — “Turn this into an executable plan. Ask clarifying questions.” Iterate until satisfied. Mermaid in markdown helps review (e.g. in Obsidian).
3. **Execution** — “Ultrawork on the latest plan.” Start the next ideation while it runs.

Tip: finalize the plan (leave draft mode) before switching to the execution agent if `/start-work` does not match your expectations.

## Tools

### [Zed](https://zed.dev/)

Fast native editor with a strong agent story. Same team lineage as Atom.

### [OpenCode](https://opencode.ai/) + [Oh My OpenCode](https://github.com/code-yeongyu/oh-my-opencode)

OpenCode is the harness; Oh My OpenCode replaces default agents with a fuller multi-agent setup.

## API keys

Keys live in the environment (not in this repo). Sync from Bitwarden:

```fish
env-sync           # smart sync
env-sync --force   # refresh all
env-sync --help
```

Requirements: `bw` (logged in), `jq`, and a Bitwarden item named **API Keys** with custom fields per variable.

Values are written to `~/.config/fish/conf.d/env-sync-vars.fish` (mode `600`) for new shells.

Common variables: `XAI_API_KEY`, `MISTRAL_API_KEY`, `OPENROUTER_API_KEY`, `GOOGLE_API_KEY`, `GEMINI_API_KEY`, etc.

## Shell (Fish)

### Shared

- Git abbreviations: `g`, `gs`, `gc` (clone), `gpush`, `gpull`
- `env-sync` function

### Linux (`os/linux/fish/conf.d/`)

- CachyOS system config (if present)
- `keychain` → `monster-github` (8h)
- `SUDO_ASKPASS` → `~/.local/bin/sudo-askpass`

### macOS (`os/macos/fish/conf.d/`)

- `keychain` → `monster-github` (8h)

## OpenCode

### Base (`opencode/opencode.json`)

- Plugin: Oh My OpenCode
- Default model: `xai/grok-code-fast-1`
- Playwright MCP enabled (browser path comes from OS overlay on Linux)
- `sudo *` → ask; other bash → allow

### Profiles

| Profile | File | Use |
|---------|------|-----|
| `cloud` | `opencode/profiles/cloud.json` | Kimi-for-Coding tiers (default) |
| `homelab` | `opencode/profiles/homelab.json` | Local `homelab/qwen/…` models |

### Agents (cloud profile)

Tiered Kimi models across build/plan/sisyphus/oracle/explore/etc. See `opencode/profiles/cloud.json`.

### `AGENTS.md`

Rules for agents in any project: separation of concerns, testing (Playwright MCP), conventional commits.

## Zed

- Shared: `zed/settings.json` (theme, fonts, default agent model)
- macOS keymap: `os/macos/zed/keymap.json`

| Key (macOS) | Action |
|-------------|--------|
| `Cmd+Æ` | Toggle assistant focus |
| `Ctrl+Cmd+Right` | Quote selection to assistant |
| `Ctrl+Cmd+Left` | Insert assistant response into editor |

## Linux-only notes

### sudo-askpass

Installed by bootstrap to `~/.local/bin/sudo-askpass`. When `OPENCODE` is set and there is no TTY, sudo can use a pinentry GUI (`sudo -A`). Requires `pinentry-qt`.

### SSH setup (CachyOS)

`os/linux/setup/ssh.sh` installs deps, generates a key, writes hosts under `~/.ssh/config.d/` (does not clobber your main config), and optional KWallet PAM unlock. Fish keychain is managed by bootstrap, not by appending to `config.fish`.

### Skills

- `os/linux/skills/virtualbox-windows-vm-setup.md` — Windows VM + USB passthrough on CachyOS
