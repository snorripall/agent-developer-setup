#!/bin/bash
# Setup script for Niri custom configuration
# This symlinks custom niri settings from dotfiles

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
NIRI_CONFIG_DIR="$HOME/.config/niri"

echo "Setting up Niri custom configuration..."

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR/niri" ]; then
    echo "Error: Dotfiles niri directory not found at $DOTFILES_DIR/niri"
    exit 1
fi

# Check if niri config directory exists
if [ ! -d "$NIRI_CONFIG_DIR" ]; then
    echo "Error: Niri config directory not found at $NIRI_CONFIG_DIR"
    exit 1
fi

# Backup existing custom.kdl if it's not a symlink
if [ -f "$NIRI_CONFIG_DIR/custom.kdl" ] && [ ! -L "$NIRI_CONFIG_DIR/custom.kdl" ]; then
    echo "Backing up existing custom.kdl..."
    mv "$NIRI_CONFIG_DIR/custom.kdl" "$NIRI_CONFIG_DIR/custom.kdl.backup.$(date +%Y%m%d)"
fi

# Remove existing symlink if present
if [ -L "$NIRI_CONFIG_DIR/custom.kdl" ]; then
    echo "Removing existing symlink..."
    rm "$NIRI_CONFIG_DIR/custom.kdl"
fi

# Create symlink
ln -s "$DOTFILES_DIR/niri/custom.kdl" "$NIRI_CONFIG_DIR/custom.kdl"
echo "Created symlink: $NIRI_CONFIG_DIR/custom.kdl -> $DOTFILES_DIR/niri/custom.kdl"

# Check if custom.kdl is included in config.kdl
if ! grep -q 'include "custom.kdl"' "$NIRI_CONFIG_DIR/config.kdl"; then
    echo ""
    echo "⚠️  Warning: custom.kdl is not included in config.kdl"
    echo "Add this line to your ~/.config/niri/config.kdl:"
    echo '    include "custom.kdl"'
    echo ""
    echo "Suggested location: After the DMS includes, before the closing brace"
fi

echo ""
echo "✓ Niri custom configuration setup complete!"
echo "Reload Niri config with: Mod+F5 or Mod+Alt+R"