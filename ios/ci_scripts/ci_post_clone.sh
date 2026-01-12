#!/bin/sh
set -e

# Installer Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# Précache iOS artifacts
flutter precache --ios

# Aller à la racine du projet
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Récupérer les dépendances Flutter (OBLIGATOIRE avant pod install)
flutter pub get

# Installer les pods
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install
