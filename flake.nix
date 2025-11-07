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
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        # Seulement les fichiers nécessaires pour la compilation
        src = pkgs.lib.sourceByRegex ./. [
          "^Cargo\\.toml$"
          "^Cargo\\.lock$"
          "^src(/.*)?$"
          "^data(/.*)?$"
        ];

        nativeBuildInputs = with pkgs; [ rustToolchain pkg-config cmake ];

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

          cargoHash = "sha256-aS9o9sxamONfuBhlkj7pwjGMQ8O3S9qdVmw5x5mbNAg=";

          inherit nativeBuildInputs buildInputs;

          # Variables d'environnement pour la compilation
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

          postInstall = ''
            install -Dm644 data/cosmic-applet-spotify.desktop \
              $out/share/applications/cosmic-applet-spotify.desktop
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
            # Outils de développement supplémentaires
            rust-analyzer
            clippy
            rustfmt
          ]);

          # Variables d'environnement pour le développement
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          PKG_CONFIG_PATH =
            "${pkgs.wayland}/lib/pkgconfig:${pkgs.libxkbcommon}/lib/pkgconfig";

          shellHook = ''
            echo "🚀 Environnement de développement COSMIC Spotify Applet"
            echo "Commandes disponibles:"
            echo "  cargo build          - Compiler en mode debug"
            echo "  cargo build --release - Compiler en mode release"
            echo "  cargo run            - Lancer l'applet"
            echo "  cargo clippy         - Vérifier le code"
            echo "  cargo fmt            - Formater le code"
            echo ""
            echo "Variables d'environnement configurées:"
            echo "  WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
            echo "  LD_LIBRARY_PATH configuré avec wayland, libxkbcommon, etc."
          '';
        };

        # Pour NixOS, module d'installation système
        nixosModules.default = { config, lib, pkgs, ... }:
          with lib;
          let cfg = config.programs.cosmic-applet-spotify;
          in {
            options.programs.cosmic-applet-spotify = {
              enable = mkEnableOption "COSMIC Spotify applet";

              package = mkOption {
                type = types.package;
                default = self.packages.${system}.default;
                description = "The cosmic-applet-spotify package to use";
              };
            };

            config = mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];

              # S'assurer que D-Bus est disponible
              services.dbus.enable = true;
            };
          };
      });
}
