#!/bin/sh
# Installer Node via Homebrew
brew install node

# Installer les dépendances npm
cd "$CI_PRIMARY_REPOSITORY_PATH"
npm install

# Installer les pods
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install
