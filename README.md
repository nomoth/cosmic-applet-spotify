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

### NixOS (Recommended)

Add this to your `configuration.nix` or `home-manager` configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cosmic-applet-spotify.url = "github:nomoth/cosmic-applet-spotify";
  };

  outputs = { self, nixpkgs, cosmic-applet-spotify, ... }: {
    nixosConfigurations.yourHostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            cosmic-applet-spotify.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
```

Or using the provided NixOS module:

```nix
{
  inputs.cosmic-applet-spotify.url = "github:nomoth/cosmic-applet-spotify";

  outputs = { cosmic-applet-spotify, ... }: {
    nixosConfigurations.yourHostname = {
      imports = [
        cosmic-applet-spotify.nixosModules.default
      ];

      programs.cosmic-applet-spotify.enable = true;
    };
  };
}
```

Or with flakes directly:

```bash
# Try it without installing
nix run github:nomoth/cosmic-applet-spotify

# Install to your profile
nix profile install github:nomoth/cosmic-applet-spotify
```

### Manual Installation

```bash
# Build with Nix
nix build

# Copy files manually
sudo cp result/bin/cosmic-applet-spotify /usr/local/bin/
cp result/share/applications/cosmic-applet-spotify.desktop ~/.local/share/applications/
```

### Development Installation

```bash
# Enter development shell
nix develop

# Build and test
cargo build --release
./target/release/cosmic-applet-spotify
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
