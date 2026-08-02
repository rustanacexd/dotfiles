# Repository Guidelines

## Project Structure & Module Organization

This repository is a flat collection of macOS setup files. `Brewfile` is the package manifest; `brew-backup.sh` regenerates it from the current machine, and `brew-restore.sh` installs it. Terminal and shell snapshots live at the repository root: `.zshrc`, `.vimrc`, `.tmux.conf`, `ghosttyconfig`, `kitty.conf`, `open-actions.conf`, and `starship.toml`. Editor and application settings are stored in `vscodesettings.json` and `slimconfig.json`. There are no generated source directories, assets, or test folders.

## Build, Test, and Development Commands

- `./brew-backup.sh` rewrites `Brewfile` from installed Homebrew packages. Review the resulting diff before committing.
- `brew bundle check --file=Brewfile` verifies that the declared packages are installed without changing the manifest.
- `./brew-restore.sh` installs all entries in `Brewfile`; use deliberately because it changes the local machine.
- `bash -n brew-backup.sh brew-restore.sh` checks shell-script syntax.
- `shellcheck brew-backup.sh brew-restore.sh` performs static analysis.
- `zsh -n .zshrc` and `jq empty vscodesettings.json slimconfig.json` validate shell and JSON configuration.

## Coding Style & Naming Conventions

Shell scripts target Bash, use four-space indentation, quote variable expansions, and begin with `set -euo pipefail`. Prefer uppercase names for script-wide constants such as `BREWFILE`, and resolve paths relative to the script rather than the caller's working directory. Preserve the native syntax and ordering conventions of each application config. Keep filenames aligned with their consuming tool; avoid introducing renamed copies unless the README documents how to install them.

## Testing Guidelines

There is no automated test suite. Run the relevant syntax checks above, then inspect `git diff --check` and `git diff`. For Homebrew changes, run `brew bundle check --file=Brewfile`; do not run a full restore solely as a test. Manually launch the affected shell or terminal application when changing its configuration.

## Commit & Pull Request Guidelines

Recent history favors concise, imperative subjects, increasingly with Conventional Commit scopes, for example `chore(brew): remove unused packages` and `feat(kitty): add scrollback nvim integration`. Keep each commit focused on one tool or workflow. Pull requests should explain the user-visible effect, list validation performed, and call out packages added or removed. Include screenshots only for visual terminal or prompt changes. Never commit credentials, tokens, machine-specific secrets, or unreviewed package dumps.
