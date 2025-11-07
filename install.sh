#!/usr/bin/env bash
# Installation script for cosmic-applet-spotify

set -e

echo "🚀 Installing cosmic-applet-spotify"
echo ""

# Check if binary exists
if [ ! -f "target/release/cosmic-applet-spotify" ]; then
    echo "❌ Binary not found. Building..."
    cargo build --release
fi

# Create necessary directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

# Copy files
echo "📦 Copying files..."
cp target/release/cosmic-applet-spotify ~/.local/bin/
cp cosmic-applet-spotify.desktop ~/.local/share/applications/

# Make binary executable
chmod +x ~/.local/bin/cosmic-applet-spotify

echo ""
echo "✅ Installation complete!"
echo ""
echo "To use the applet:"
echo "1. Restart COSMIC panel: cosmic-panel restart"
echo "2. Go to Settings → Panel → Applets"
echo "3. Add 'Spotify Player' to the panel"
echo ""
echo "Note: Spotify must be running for the applet to work."
