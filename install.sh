#!/usr/bin/env bash
# Script d'installation pour cosmic-applet-spotify

set -e

echo "🚀 Installation de cosmic-applet-spotify"
echo ""

# Vérifier que le binaire existe
if [ ! -f "target/release/cosmic-applet-spotify" ]; then
    echo "❌ Binaire non trouvé. Compilation en cours..."
    cargo build --release
fi

# Créer les répertoires nécessaires
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

# Copier les fichiers
echo "📦 Copie des fichiers..."
cp target/release/cosmic-applet-spotify ~/.local/bin/
cp cosmic-applet-spotify.desktop ~/.local/share/applications/

# Rendre le binaire exécutable
chmod +x ~/.local/bin/cosmic-applet-spotify

echo ""
echo "✅ Installation terminée !"
echo ""
echo "Pour utiliser l'applet :"
echo "1. Redémarrer le panneau COSMIC : cosmic-panel restart"
echo "2. Aller dans Paramètres → Panneau → Applets"
echo "3. Ajouter 'Spotify Player' au panneau"
echo ""
echo "Note : Spotify doit être lancé pour que l'applet fonctionne."
