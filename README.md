# Dotfiles

Managed with standard tools:

- **chezmoi** for dotfiles, shell configs, Oh My Zsh plugins, and LaunchAgents
- **Homebrew (`~/.Brewfile`)** for macOS apps, CLI tools, and Cargo crates
- **mise (`~/.config/mise/config.toml`)** for language runtimes (`python`, `node`, `bun`, `go`, `java`) and global `npm`, `pypi`, and `go` CLIs

## Day-to-day workflow (machine → repo)

```sh
# Pull edited dotfiles and mise.toml changes back into the repo
chezmoi diff
chezmoi re-add

# Snapshot Homebrew packages into ~/.Brewfile, then pull into the repo
brew bundle dump --global --force && chezmoi re-add ~/.Brewfile

# Commit and push
chezmoi git -- add -A
chezmoi git -- commit -m "chore: sync dotfiles"
chezmoi git -- push
```

When installing new language tools, use `mise use -g` so `~/.config/mise/config.toml` updates automatically:

```sh
mise use -g npm:vercel
mise use -g pypi:posting
chezmoi re-add ~/.config/mise/config.toml
```

## New Mac setup

1. Install Homebrew from https://brew.sh.
2. Install `chezmoi` and apply this repo (runs `brew bundle` and `mise install` automatically):
   ```sh
   brew install chezmoi
   chezmoi init --apply rustanacexd
   ```
3. Install vendor tools that manage themselves:
   - `rustup`: `curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path`
   - Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
   - Zed: `curl -fsSL https://zed.dev/install.sh | sh`
4. Recreate local secret files (never committed):
   - `~/.zshenv.secrets` (mode 600): `export EXA_API_KEY=...`
   - `~/.zshrc.secrets` (mode 600): `export AWS_ACCESS_KEY_ID=...`, `AWS_SECRET_ACCESS_KEY`, `GEMINI_API_KEY`, `GOOGLE_GENERATIVE_AI_API_KEY`
5. Open OrbStack and Karabiner-Elements once to finish permissions, then log out and back in.
