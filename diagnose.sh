#!/usr/bin/env bash
# Diagnostic script for cosmic-applet-spotify

echo "=== Environment Diagnostics ==="
echo ""

echo "1. Wayland Session:"
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "   ✅ WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
else
    echo "   ❌ WAYLAND_DISPLAY not set"
fi

if [ -n "$XDG_SESSION_TYPE" ]; then
    echo "   Session type: $XDG_SESSION_TYPE"
fi
echo ""

echo "2. Wayland Libraries:"
if [ -n "$LD_LIBRARY_PATH" ]; then
    echo "   LD_LIBRARY_PATH is set"
    echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -i wayland | head -3
else
    echo "   ⚠️  LD_LIBRARY_PATH not set"
fi
echo ""

echo "3. System Libraries Check:"
for lib in libwayland-client.so libxkbcommon.so libdbus-1.so; do
    if ldconfig -p 2>/dev/null | grep -q "$lib"; then
        echo "   ✅ $lib found"
    else
        echo "   ❌ $lib not found"
    fi
done
echo ""

echo "4. Compiled Binary:"
if [ -f "target/debug/cosmic-applet-spotify" ]; then
    echo "   ✅ target/debug/cosmic-applet-spotify exists"
    echo "   Wayland dependencies:"
    ldd target/debug/cosmic-applet-spotify 2>/dev/null | grep -i wayland || echo "   ⚠️  Unable to verify with ldd"
elif [ -f "target/release/cosmic-applet-spotify" ]; then
    echo "   ✅ target/release/cosmic-applet-spotify exists"
    echo "   Wayland dependencies:"
    ldd target/release/cosmic-applet-spotify 2>/dev/null | grep -i wayland || echo "   ⚠️  Unable to verify with ldd"
else
    echo "   ❌ Binary not compiled"
    echo "   Run: cargo build"
fi
echo ""

echo "5. D-Bus and Spotify:"
if command -v dbus-send &> /dev/null; then
    if dbus-send --print-reply --session --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | grep -q spotify; then
        echo "   ✅ Spotify detected on D-Bus"
    else
        echo "   ⚠️  Spotify not detected on D-Bus (launch Spotify)"
    fi
else
    echo "   ⚠️  dbus-send not available"
fi
echo ""

echo "=== Recommendations ==="
echo ""
if [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ You are not in a Wayland session"
    echo "   The applet only works under Wayland"
elif [ ! -f "target/debug/cosmic-applet-spotify" ] && [ ! -f "target/release/cosmic-applet-spotify" ]; then
    echo "⚠️  Compile the applet first:"
    echo "   cargo build"
else
    echo "✅ Everything looks OK. If the error persists:"
    echo "   1. Exit nix-shell: exit"
    echo "   2. Restart: nix develop"
    echo "   3. Rebuild: cargo build"
fi
