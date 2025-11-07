#!/usr/bin/env bash
# Script de diagnostic pour cosmic-applet-spotify

echo "=== Diagnostic de l'environnement ==="
echo ""

echo "1. Session Wayland:"
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "   ✅ WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
else
    echo "   ❌ WAYLAND_DISPLAY non défini"
fi

if [ -n "$XDG_SESSION_TYPE" ]; then
    echo "   Session type: $XDG_SESSION_TYPE"
fi
echo ""

echo "2. Bibliothèques Wayland:"
if [ -n "$LD_LIBRARY_PATH" ]; then
    echo "   LD_LIBRARY_PATH est défini"
    echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -i wayland | head -3
else
    echo "   ⚠️  LD_LIBRARY_PATH non défini"
fi
echo ""

echo "3. Vérification des bibliothèques système:"
for lib in libwayland-client.so libxkbcommon.so libdbus-1.so; do
    if ldconfig -p 2>/dev/null | grep -q "$lib"; then
        echo "   ✅ $lib trouvé"
    else
        echo "   ❌ $lib non trouvé"
    fi
done
echo ""

echo "4. Binaire compilé:"
if [ -f "target/debug/cosmic-applet-spotify" ]; then
    echo "   ✅ target/debug/cosmic-applet-spotify existe"
    echo "   Dépendances wayland:"
    ldd target/debug/cosmic-applet-spotify 2>/dev/null | grep -i wayland || echo "   ⚠️  Impossible de vérifier avec ldd"
elif [ -f "target/release/cosmic-applet-spotify" ]; then
    echo "   ✅ target/release/cosmic-applet-spotify existe"
    echo "   Dépendances wayland:"
    ldd target/release/cosmic-applet-spotify 2>/dev/null | grep -i wayland || echo "   ⚠️  Impossible de vérifier avec ldd"
else
    echo "   ❌ Binaire non compilé"
    echo "   Exécutez: cargo build"
fi
echo ""

echo "5. D-Bus et Spotify:"
if command -v dbus-send &> /dev/null; then
    if dbus-send --print-reply --session --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | grep -q spotify; then
        echo "   ✅ Spotify détecté sur D-Bus"
    else
        echo "   ⚠️  Spotify non détecté sur D-Bus (lancez Spotify)"
    fi
else
    echo "   ⚠️  dbus-send non disponible"
fi
echo ""

echo "=== Recommandations ==="
echo ""
if [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ Vous n'êtes pas dans une session Wayland"
    echo "   L'applet ne peut fonctionner que sous Wayland"
elif [ ! -f "target/debug/cosmic-applet-spotify" ] && [ ! -f "target/release/cosmic-applet-spotify" ]; then
    echo "⚠️  Compilez d'abord l'applet:"
    echo "   cargo build"
else
    echo "✅ Tout semble OK. Si l'erreur persiste:"
    echo "   1. Sortez du nix-shell: exit"
    echo "   2. Relancez: nix develop"
    echo "   3. Recompilez: cargo build"
fi
