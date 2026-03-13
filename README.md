# Dotfiles

Personal macOS setup assets and Homebrew state backups.

This repo is the source of truth for:
- Homebrew packages/apps/taps/extensions (`Brewfile`)
- Terminal prompt and app config snapshots
- Repeatable backup/restore scripts for Homebrew

## Repository Layout

- `Brewfile`: Managed package list for `brew bundle` (taps, formulas, casks, VS Code extensions, and additional bundle entries)
- `brew-backup.sh`: Dumps current machine state into `Brewfile`
- `brew-restore.sh`: Installs from `Brewfile`
- `ghosttyconfig`: Ghostty terminal configuration snapshot
- `kitty.conf`: Kitty terminal configuration snapshot
- `open-actions.conf`: Kitty open actions rules snapshot
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
```

Notes:
- `brew-restore.sh` resolves `Brewfile` relative to the script path, so it can be run from any directory.
- Restore can take a while depending on casks/formulas.

## Homebrew Workflow (Day 2+)

When you install/remove tooling on your machine and want this repo updated:

```bash
./brew-backup.sh
git diff Brewfile
git add Brewfile
git commit -m "chore(brew): update Brewfile"
```

What gets captured in `Brewfile`:
- `tap`: additional formula repositories
- `brew`: CLI packages and libraries
- `cask`: GUI applications

## Config Files in This Repo

This repo currently stores raw config snapshots, not an automated symlink/stow system.

If you want to apply a file manually:
- Ghostty: copy/sync `ghosttyconfig` to your Ghostty config location.
- Kitty: copy/sync `kitty.conf` and `open-actions.conf` to `~/.config/kitty/`.
- Starship: point `STARSHIP_CONFIG` to this repo file or copy it to your default location.

## Maintenance Rules

- After package changes, run `./brew-backup.sh` and commit `Brewfile`.
- Before wiping/reprovisioning a machine, run `./brew-backup.sh` one last time.
- Keep this README aligned with actual files in this repo.

## Troubleshooting

- `Brewfile not found`: ensure the repo still contains `Brewfile`.
- `brew: command not found`: install Homebrew and re-open shell.
- Partial restore failures: re-run `./brew-restore.sh`; `brew bundle` is designed to be repeatable.
