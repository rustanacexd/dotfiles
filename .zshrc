# ------------------------------------------------------------------------------
# ~/.zshrc
# Built-in README for your shell setup.
#
# Load order:
# 1) Locale / Environment variables
# 2) PATH assembly (deduped)
# 3) Oh My Zsh + plugin loading
# 4) Tool initialization (fzf/terraform/gcloud/bun/starship/direnv)
# 5) Aliases
# 6) Custom functions
# 7) Local secrets file (private, machine-specific)
# ------------------------------------------------------------------------------

# 1) Locale / Environment
# Prevent locale warnings and keep UTF-8 behavior consistent across tools.
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Oh My Zsh and runtime helpers.
export ZSH="$HOME/.oh-my-zsh"
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_DIR="$HOME/.nvm"

# Python environment roots/settings.
export PYENV_ROOT="$HOME/.pyenv"

# General tool behavior flags.
export ENABLE_BACKGROUND_TASKS=1
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export DISABLE_PURE=false

# Bun install root (bin path added in PATH section).
export BUN_INSTALL="$HOME/.bun"

export FORCE_AUTOUPDATE_PLUGINS=true

# 2) PATH (deduped, one place)
# `path` is zsh's array version of PATH; `PATH` is the colon-separated string.
# `typeset -U path PATH` keeps both unique: duplicate directories are removed
# and the first occurrence wins (order is otherwise preserved).
# This avoids PATH bloat and command-resolution surprises across reloads.
typeset -U path PATH

# Prepend preferred binaries first, then keep existing inherited PATH at end.
path=(
  "$HOME/.local/bin"
  "/opt/homebrew/opt/openssl@3/bin"
  "/opt/homebrew/opt/openjdk/bin"
  "/opt/homebrew/opt/ffmpeg-full/bin"
  "/opt/homebrew/opt/imagemagick-full/bin"
  "$BUN_INSTALL/bin"
  $path
)

# 3) oh-my-zsh + plugins
# Plugin list:
# - fzf-tab: fuzzy tab completion UI
# - zsh-bat: nicer cat-like previews through bat integration
# - zsh-nvm: nvm integration/lazy behavior
plugins=(fzf-tab zsh-bat zsh-nvm)
source "$ZSH/oh-my-zsh.sh"

# 4) Tool Init
# Load fzf key bindings/completions only for full interactive sessions
# (avoids zle warnings when running `zsh -i -c ...`).
if [[ -o interactive && -z "$ZSH_EXECUTION_STRING" ]] && (( $+commands[fzf] )); then
  eval "$(fzf --zsh)"
fi

# Default file source for fzf if not already set by other configs.
if [[ -z "$FZF_DEFAULT_COMMAND" ]]; then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  elif (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
  elif (( $+commands[ag] )); then
    export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git'
  fi
fi

# Google Cloud SDK path helper.
# This script appends Google Cloud SDK binaries to PATH when installed.
if [[ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]]; then
  source '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
fi

# Prompt + environment-directory hooks.
# starship: prompt renderer
# direnv: auto-loads .envrc per directory
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# 5) Aliases
# Navigation shortcuts.
alias work="cd ~/code"
alias notes='cd ~/code/notes'
alias todo='notes && nvim go2/todo.md'

# Basic shell convenience aliases.
alias pg="ping google.com"
alias c='clear'
alias x='exit'
alias fsize='du -hs'

# Tool launch shortcuts.
alias lg='lazygit'
alias lzd='lazydocker'
alias htop="sudo /Applications/NeoHtop.app/Contents/MacOS/NeoHtop"

# Sets ADC path in current shell for GCP SDK/client usage.
alias export_gcs_creds='export GOOGLE_APPLICATION_CREDENTIALS="/Users/rustancorpuz/.config/gcloud/application_default_credentials.json"'

# AI CLI shortcuts.
alias cx="codex --yolo"
alias cc="claude --dangerously-skip-permissions"
alias oc="opencode"

# Plugin updates.
alias update-omos='bun update -g oh-my-opencode-slim'

# Homebrew package update checks (Homebrew-installed packages don't auto-notify)
alias check-opencode='brew update 2>/dev/null && brew outdated opencode 2>/dev/null || echo "opencode: up to date"'

# 6) Functions
# Lazy pyenv initialization for faster shell startup.
pyenv() {
  unfunction pyenv
  eval "$(command pyenv init -)"
  eval "$(command pyenv virtualenv-init -)"
  pyenv "$@"
}

cpcommands() {
  # Copy markdown commands from Claude commands dir into a destination dir.
  local dest_dir="$1"
  local src_dir="$HOME/.claude/commands"

  if [[ -z "$dest_dir" ]]; then
    echo "Usage: cpcommands <destination-directory>"
    return 1
  fi

  find "$src_dir" -maxdepth 1 -name "*.md" ! -name "README.md" -exec cp {} "$dest_dir" \;
}

# Kill orphaned AI coding agent processes (keeps current session alive)
ai-cleanup() {
  # Safety: skips current parent shell process and only targets stale workers.
  local parent_pid="$PPID"
  local killed=0

  # Claude Code: kill processes older than 2 hours
  for pid in $(pgrep -x claude); do
    [[ "$pid" == "$parent_pid" ]] && continue
    local etime
    etime="$(ps -o etime= -p "$pid" 2>/dev/null | xargs)"
    if echo "$etime" | grep -q -- '-\|^[0-9]\{2,\}:'; then
      kill "$pid" 2>/dev/null && ((killed++))
    fi
  done

  # Codex: kill orphaned codex processes older than 2 hours
  for pid in $(pgrep -f 'codex' | grep -v "$$"); do
    local etime
    etime="$(ps -o etime= -p "$pid" 2>/dev/null | xargs)"
    if echo "$etime" | grep -q -- '-\|^[0-9]\{2,\}:'; then
      kill "$pid" 2>/dev/null && ((killed++))
    fi
  done

  echo "Cleaned up $killed orphaned AI process(es)."
}

# 7) Local Secrets (not committed)
[[ -f "$HOME/.zshrc.secrets" ]] && source "$HOME/.zshrc.secrets"

# bun completions
[ -s "/Users/rustancorpuz/.bun/_bun" ] && source "/Users/rustancorpuz/.bun/_bun"

# browser-use CLI: do not prepend ~/.browser-use-env to PATH globally — it hijacks
# `python` for every shell. Use `uv run` / project venvs for Python, or activate
# that env only when working on browser-use.

# pnpm
export PNPM_HOME="/Users/rustancorpuz/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
