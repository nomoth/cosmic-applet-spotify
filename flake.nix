{
  description = "COSMIC applet for displaying current Spotify track";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        # Only necessary files for compilation
        src = pkgs.lib.sourceByRegex ./. [
          "^Cargo\\.toml$"
          "^Cargo\\.lock$"
          "^src(/.*)?$"
          "^data(/.*)?$"
        ];

        nativeBuildInputs = with pkgs; [
          rustToolchain
          pkg-config
          cmake
          makeWrapper
        ];

        buildInputs = with pkgs; [
          expat
          fontconfig
          freetype
          libxkbcommon
          wayland
          wayland-protocols
          libGL
          dbus
        ];

      in {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "cosmic-applet-spotify";
          version = "0.1.0";

          inherit src;

          cargoHash = "sha256-lXbSYFKP3CCej7neLz/CmLiTPvG4edbdxFDxCHVSvME=";

          inherit nativeBuildInputs buildInputs;

          # Environment variables for compilation
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

          postInstall = ''
            install -Dm644 data/cosmic-applet-spotify.desktop \
              $out/share/applications/cosmic-applet-spotify.desktop

            install -Dm644 data/icons/scalable/apps/cosmic-applet-spotify.svg \
              $out/share/icons/hicolor/scalable/apps/cosmic-applet-spotify.svg

            ln -sf cosmic-applet-spotify.svg \
              $out/share/icons/hicolor/scalable/apps/spotify.svg

            # Wrap binary to ensure wayland libraries are found at runtime
            wrapProgram $out/bin/cosmic-applet-spotify \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
                pkgs.wayland
                pkgs.libGL
                pkgs.libxkbcommon
              ]}
          '';

          meta = with pkgs.lib; {
            description = "COSMIC applet for displaying current Spotify track";
            homepage = "https://github.com/nomoth/cosmic-applet-spotify";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.linux;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit buildInputs;

          nativeBuildInputs = nativeBuildInputs ++ (with pkgs; [
            # Additional development tools
            rust-analyzer
            clippy
            rustfmt
          ]);

          # Environment variables for development
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          PKG_CONFIG_PATH =
            "${pkgs.wayland}/lib/pkgconfig:${pkgs.libxkbcommon}/lib/pkgconfig";

          shellHook = ''
            echo "🚀 COSMIC Spotify Applet Development Environment"
            echo "Available commands:"
            echo "  cargo build           - Build in debug mode"
            echo "  cargo build --release - Build in release mode"
            echo "  cargo run             - Run the applet"
            echo "  cargo clippy          - Check the code"
            echo "  cargo fmt             - Format the code"
            echo ""
            echo "Environment variables configured:"
            echo "  WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
            echo "  LD_LIBRARY_PATH configured with wayland, libxkbcommon, etc."
          '';
        };
      })) // {
        # NixOS module for system-wide installation
        nixosModules.default = { config, lib, pkgs, ... }:
          with lib;
          let cfg = config.programs.cosmic-applet-spotify;
          in {
            options.programs.cosmic-applet-spotify = {
              enable = mkEnableOption "COSMIC Spotify applet";

              package = mkOption {
                type = types.package;
                default = self.packages.${pkgs.system}.default;
                description = "The cosmic-applet-spotify package to use";
              };
            };

            config = mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];

              # Ensure D-Bus is available
              services.dbus.enable = true;
            };
          };
      };
}
