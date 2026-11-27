# AGENTS.md

This repo is the chezmoi source for Rustan's Mac (`~/.local/share/chezmoi`, pushed to `github.com/rustanacexd/dotfiles`, which is **public**). When he says "maintain my setup", work through this file. `README.md` explains the design to people; this file tells you how to change things safely.

## Who owns what

| Thing | Owner | Edit here | Then |
|---|---|---|---|
| Shell, tmux, vim, ghostty, starship, uv configs, LaunchAgents | chezmoi | `dot_*` / `private_*` in this repo | `chezmoi apply` |
| Homebrew formulae, casks, taps, cargo crates | Homebrew | `brew install …` on the machine | `brew bundle dump --global --force`, then `chezmoi re-add ~/.Brewfile` |
| Language runtimes, global npm/pypi/go CLIs | mise | `mise use -g <tool>` | `chezmoi re-add ~/.config/mise/config.toml` |
| rustup, Claude Code, Zed | their own installers | nothing | not tracked |
| Secrets **and private identifiers** | `~/.zshenv.secrets`, `~/.zshrc.secrets` (mode 600) | those files only | never committed |

`chezmoi managed --include=files` lists every tracked file. Do not add npm, pypi, or go tools to the Brewfile: `dot_zshenv` sets `HOMEBREW_BUNDLE_DUMP_NO_{NPM,GO,UV,MAS,VSCODE}` so dumps leave them to mise.

## Editing rules

- Edit the source file in this repo, then `chezmoi apply <target>`. If someone edited the live file (`~/.zshrc`) instead, `chezmoi diff` shows it; pull it in with `chezmoi re-add <target>`.
- Vendor installers append lines to `~/.zshrc` / `~/.bashrc` (for example "Added by Antigravity CLI installer"). Re-add them, or delete them if `dot_zshenv` already covers that PATH entry.
- Zsh startup order: `dot_zshenv` (every zsh, including scripts and agents) → `dot_zprofile` (login) → `dot_zshrc` (interactive). PATH lives in `dot_zshenv` and is re-asserted in `dot_zprofile`; keep both lists identical. Bash mirrors this in `dot_bashrc`.
- `dot_zshrc` and `dot_bashrc` source `~/.zshrc.secrets` before the `agy()` block, because that block reads its variables. Anything new that reads a secret goes after that line.
- After editing a shell file, run `zsh -n ~/.zshrc && bash -n ~/.bashrc`, then open a real shell with `zsh -ic '…'` to see the effect.
- The two `run_onchange_after_*.sh.tmpl` scripts rerun when the hashed files change: a Brewfile or mise change runs `brew bundle --no-upgrade` and `mise install`; a LaunchAgent change reloads it with launchctl. Changing those files on `apply` installs software, so say so first.
- Files that should not land in `~` (README, AGENTS.md, `.githooks`) go in `.chezmoiignore`.

## Secrets: this repo is public

- Nothing private goes in a tracked file: no keys or tokens, and also no account IDs, GCP project IDs, service-account filenames, internal hostnames, or emails beyond the commit author. Put the value in a secrets file as a variable and reference the variable (see `AGY_GCP_CREDENTIALS` / `AGY_GCP_PROJECT` used by `agy()` in `dot_zshrc`).
- When you verify that a secret loads, print its name or length, never its value. `env | grep GOOGLE_` also prints `GOOGLE_GENERATIVE_AI_API_KEY`; filter names with `env | cut -d= -f1`.
- `.githooks/pre-commit` runs trufflehog on staged files and blocks the commit if it finds anything. `core.hooksPath` is set by the install script. Never bypass it with `--no-verify`.
- If something private was already pushed:
  1. If it is a credential, tell Rustan to revoke and reissue it. Rewriting history does not undo a leak.
  2. Move the value into a secrets file and reference a variable instead.
  3. If it is in the newest commit: `git commit --amend -a --no-edit && git push --force-with-lease`. If it is deeper, ask before rewriting with `git filter-repo`.
  4. Confirm with `git log -S '<string>' HEAD` (prints nothing when clean) and `git ls-remote origin main`.
  Force-push only for this, and only to `main` of this repo.

## Routine maintenance

Health check (all read-only):

```sh
chezmoi status | grep -v oh-my-zsh          # source vs. machine drift
chezmoi diff
brew bundle check --global --no-upgrade     # without --no-upgrade it reports outdated packages as missing
brew bundle dump --global --force && chezmoi diff ~/.Brewfile   # what's installed but untracked
mise outdated
chezmoi git -- status --short
```

Sync the machine to GitHub:

```sh
brew bundle dump --global --force
chezmoi re-add
chezmoi git -- add -A
chezmoi git -- commit -m "chore: sync dotfiles"
chezmoi git -- push
```

Read the diff before committing. A cask missing from the dump usually means it was uninstalled by hand. Ask whether to drop it or reinstall it; don't decide alone.

Commit messages use conventional prefixes (`chore:`, `feat(shell):`, `docs:`). Commit and push routine syncs yourself; ask before anything that uninstalls software or rewrites history.

## Known issues and fixes

- **`brew bundle dump` warns "circular dependency: libtiff, webp".** A stale install receipt. Reinstall the package whose receipt lists the other one (`jq '.runtime_dependencies[].full_name' $(brew --cellar)/webp/*/INSTALL_RECEIPT.json`); in Nov 2026 that was `brew reinstall webp`. Don't run the warning's `uninstall --ignore-dependencies` steps.
- **New Mac: install rustup before `chezmoi init --apply`.** The Brewfile has `cargo` entries; if no cargo exists, `brew bundle` silently installs Homebrew's `rust` formula and you end up with two toolchains.
- **`pi` must run on mise's global Node.** The `pi()` wrapper in `dot_zshrc` does this so per-project Node versions don't break it. Keep it.

## Keep docs current

When a change alters what `README.md` describes (file tree, startup diagram, setup steps, secret variables), update the README in the same commit. Add new gotchas to "Known issues and fixes" above.
