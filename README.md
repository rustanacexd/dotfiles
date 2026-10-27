# Dotfiles

Personal macOS setup assets and Homebrew state backups.

This repo is the source of truth for:
- Homebrew packages/apps/taps/extensions (`Brewfile`)
- Shell, terminal, and prompt configs, symlinked into place
- One sync command plus backup/restore scripts for Homebrew

## Repository Layout

- `Brewfile`: Managed package list for `brew bundle` (taps, formulas, casks, VS Code extensions, and additional bundle entries)
- `brew-backup.sh`: Dumps current machine state into `Brewfile`
- `brew-restore.sh`: Installs from `Brewfile`
- `sync.sh`: Links configs, backs up Homebrew, validates, and optionally commits
- `.zshrc`, `.vimrc`, `.tmux.conf`: Shell, Vim, and tmux configs
- `ghosttyconfig`: Ghostty terminal configuration
- `starship.toml`: Starship prompt configuration

## Prerequisites

- macOS
- Homebrew installed and available on `PATH`

Install Homebrew if missing:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Quick Start (New Machine)

```bash
git clone <your-repo-url> ~/code/dotfiles
cd ~/code/dotfiles
./brew-restore.sh
./sync.sh
```

Notes:
- `brew-restore.sh` resolves `Brewfile` relative to the script path, so it can be run from any directory.
- Restore can take a while depending on casks/formulas.
- Run `brew-restore.sh` before `sync.sh`. Sync rewrites `Brewfile` from the installed packages, so running it first on a bare machine would empty the list.

## Sync Workflow (Day 2+)

One command updates the repo from this machine:

```bash
./sync.sh            # link configs, dump Brewfile, validate, scan for secrets, show status
./sync.sh --commit   # same, then commit any changes
```

`sync.sh` never pushes. Review the commit and push it yourself.

What it does, in order:
1. Symlinks each config into its live location. A path that is already linked is skipped. A real file found at a live path is moved to `<path>.bak.<timestamp>` first.
2. Runs `brew-backup.sh`, which rewrites `Brewfile` with `brew bundle dump`.
3. Checks `bash -n` and `shellcheck` on the scripts, `zsh -n .zshrc`, and `git diff --check`.
4. Scans the repo with `trufflehog` (offline, no verification) and stops on any finding.
5. With `--commit`, commits everything as `chore(sync): update dotfiles` if anything changed.

## Config Files

Every config is symlinked: the real file sits in this repo and the live path points to it, so editing either edits the same file.

| Repo file | Live path |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.vimrc` | `~/.vimrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `ghosttyconfig` | `~/.config/ghostty/config` |
| `starship.toml` | `~/.config/starship.toml` |

To track another config, add it to the `LINKS` table in `sync.sh` and to this table.

## Maintenance Rules

- After package or config changes, run `./sync.sh --commit`.
- Before wiping/reprovisioning a machine, run `./sync.sh --commit` and push.
- Keep this README aligned with actual files in this repo.

## Troubleshooting

- `Brewfile not found`: ensure the repo still contains `Brewfile`.
- `brew: command not found`: install Homebrew and re-open shell.
- Partial restore failures: re-run `./brew-restore.sh`; `brew bundle` is designed to be repeatable.
