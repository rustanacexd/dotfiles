# Repository Guidelines

## Project Structure & Module Organization

This repository is a flat collection of macOS setup files. `Brewfile` is the package manifest; `brew-backup.sh` regenerates it from the current machine, and `brew-restore.sh` installs it. `sync.sh` symlinks each config into its live location and runs the backup and checks in one step. The configs live at the repository root: `.zshrc`, `.vimrc`, `.tmux.conf`, `ghosttyconfig`, `starship.toml`, and `worktrunk.toml`. The live paths are symlinks to these files, so edit the repo copy. There are no generated source directories, assets, or test folders.

## Build, Test, and Development Commands

- `./sync.sh` links configs, rewrites `Brewfile`, runs the checks below, scans for secrets with `trufflehog`, and prints `git status`. `./sync.sh --commit` also commits any changes as `chore(sync): update dotfiles`. It never pushes. Use this for routine update, sync, or backup requests.
- `./brew-backup.sh` rewrites `Brewfile` from installed Homebrew packages. Review the resulting diff before committing.
- `brew bundle check --file=Brewfile` verifies that the declared packages are installed without changing the manifest.
- `./brew-restore.sh` installs all entries in `Brewfile`; use deliberately because it changes the local machine.
- `for f in *.sh; do bash -n "$f"; done` checks shell-script syntax. `bash -n` reads only its first file argument.
- `shellcheck ./*.sh` performs static analysis.
- `zsh -n .zshrc` validates shell configuration.

## Coding Style & Naming Conventions

Shell scripts target Bash, use four-space indentation, quote variable expansions, and begin with `set -euo pipefail`. Prefer uppercase names for script-wide constants such as `BREWFILE`, and resolve paths relative to the script rather than the caller's working directory. Preserve the native syntax and ordering conventions of each application config. Keep filenames aligned with their consuming tool. To track a new config, add it to the `LINKS` table in `sync.sh` and the README.

## Testing Guidelines

There is no automated test suite. Run `./sync.sh`, or the relevant syntax checks above, then inspect `git diff --check` and `git diff`. For Homebrew changes, run `brew bundle check --file=Brewfile`; do not run a full restore solely as a test. Manually launch the affected shell or terminal application when changing its configuration.

## Commit & Pull Request Guidelines

Recent history favors concise, imperative subjects, increasingly with Conventional Commit scopes, for example `chore(brew): remove unused packages` and `chore(zsh): update editor, path exports, and aliases`. Keep each commit focused on one tool or workflow. Pull requests should explain the user-visible effect, list validation performed, and call out packages added or removed. Include screenshots only for visual terminal or prompt changes. Never commit credentials, tokens, machine-specific secrets, or unreviewed package dumps. Review `git diff` before `./sync.sh --commit`.
