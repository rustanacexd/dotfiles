#!/bin/bash

# Dotfiles Sync Script
# Links configs into place, backs up Homebrew, validates, and optionally commits

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# repo file:live path
LINKS=(
    ".zshrc:$HOME/.zshrc"
    ".vimrc:$HOME/.vimrc"
    ".tmux.conf:$HOME/.tmux.conf"
    "ghosttyconfig:$HOME/.config/ghostty/config"
    "starship.toml:$HOME/.config/starship.toml"
)

COMMIT=false
case "${1:-}" in
    "") ;;
    --commit) COMMIT=true ;;
    *)
        echo "Usage: $0 [--commit]"
        exit 1
        ;;
esac

cd "$SCRIPT_DIR"

echo "🔗 Linking configs..."
for entry in "${LINKS[@]}"; do
    src="$SCRIPT_DIR/${entry%%:*}"
    dest="${entry#*:}"
    if [[ "$(readlink "$dest" || true)" == "$src" ]]; then
        continue
    fi
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "   • Moved existing $dest to $backup"
    fi
    ln -s "$src" "$dest"
    echo "   • Linked $dest"
done
echo ""

"$SCRIPT_DIR/brew-backup.sh"
echo ""

echo "🔍 Validating..."
for script in *.sh; do
    bash -n "$script"
done
shellcheck ./*.sh
zsh -n .zshrc
git diff --check

echo "🔐 Scanning for secrets..."
trufflehog filesystem . --no-verification --no-update --fail \
    --exclude-paths=<(printf '%s\n' '^\.git/') 2>/dev/null || {
    echo "❌ Possible secret found above. Remove it before committing."
    exit 1
}
echo ""

if $COMMIT; then
    git add -A
    if git diff --cached --quiet; then
        echo "✅ Nothing to commit"
    else
        git commit -m "chore(sync): update dotfiles"
        echo "✅ Committed. Push when ready."
    fi
else
    git status --short
    echo ""
    echo "💡 Review the diff, then rerun with --commit"
fi
