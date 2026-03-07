#!/bin/bash

# Homebrew Backup Script
# Generates a Brewfile containing all installed packages, casks, and taps

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

echo "🍺 Backing up Homebrew installations..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Error: Homebrew is not installed"
    echo "💡 Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Generate new Brewfile
brew bundle dump --force --file="$BREWFILE"

echo "✅ Brewfile updated successfully!"
echo ""
echo "📋 Summary:"
echo "   • Taps: $(grep -c '^tap ' "$BREWFILE")"
echo "   • Formulas: $(grep -c '^brew ' "$BREWFILE")"
echo "   • Casks: $(grep -c '^cask ' "$BREWFILE")"
echo "   • VSCode Extensions: $(grep -c '^vscode ' "$BREWFILE")"
echo ""
echo "💡 Don't forget to commit the updated Brewfile to git!"
