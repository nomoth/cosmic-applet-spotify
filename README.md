# cosmic-applet-spotify

A COSMIC applet for displaying the currently playing Spotify track in the panel.

## Features

- Displays current track information (artist and title)
- Shows playback status with icons (♫ playing, ⏸ paused, ⏹ stopped)
- Integrates seamlessly with the COSMIC panel
- Updates every 500ms

## Requirements

- COSMIC Desktop Environment
- Spotify running with MPRIS support
- Wayland

## Building

### With Nix (recommended for NixOS)

```bash
nix develop
cargo build --release
```

### Without Nix

Ensure you have the following dependencies installed:
- Rust toolchain
- libwayland
- libxkbcommon
- dbus
- pkg-config

Then build:

```bash
cargo build --release
```

## Installation

### Manual Installation

```bash
# Copy the binary
mkdir -p ~/.local/bin
cp target/release/cosmic-applet-spotify ~/.local/bin/

# Copy the desktop file
mkdir -p ~/.local/share/applications
cp data/cosmic-applet-spotify.desktop ~/.local/share/applications/

# Make the binary executable
chmod +x ~/.local/bin/cosmic-applet-spotify
```

### Adding to COSMIC Panel

1. Open COSMIC Settings
2. Go to Panel → Applets
3. Find "Spotify Player" in the list
4. Add it to your panel
5. Make sure Spotify is running

## License

MIT

## Credits

Based on the COSMIC applet architecture from [pop-os/cosmic-applets](https://github.com/pop-os/cosmic-applets).
