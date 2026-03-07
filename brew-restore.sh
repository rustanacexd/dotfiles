#!/bin/bash

# Homebrew Restore Script
# Installs all packages, casks, and taps from the Brewfile

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

echo "🍺 Restoring Homebrew installations from Brewfile..."

# Check if Brewfile exists
if [[ ! -f "$BREWFILE" ]]; then
    echo "❌ Error: Brewfile not found at: $BREWFILE"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Error: Homebrew is not installed"
    echo "💡 Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "📋 Brewfile contains:"
echo "   • Taps: $(grep -c '^tap ' "$BREWFILE")"
echo "   • Formulas: $(grep -c '^brew ' "$BREWFILE")"
echo "   • Casks: $(grep -c '^cask ' "$BREWFILE")"
echo "   • VSCode Extensions: $(grep -c '^vscode ' "$BREWFILE")"
echo ""

# Install everything from Brewfile
echo "⚡ Installing packages... (this may take a while)"
brew bundle install --file="$BREWFILE"

echo ""
echo "✅ All packages restored successfully!"
echo "🎉 Your Homebrew setup has been fully restored!"
