#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"
cd ..
ROOT_DIR="$PWD"

# Clean Flutter
cd "$ROOT_DIR"
flutter clean

# Remove Derived Data folders completely - this is crucial
rm -rf ~/Library/Developer/Xcode/DerivedData/* || true

# Clean CocoaPods related files
cd "$PROJECT_DIR"
rm -rf "$PROJECT_DIR/Pods"
rm -f "$PROJECT_DIR/Podfile.lock"
rm -rf "$PROJECT_DIR/.symlinks"
rm -f "$PROJECT_DIR/Flutter/Flutter.podspec"
rm -f "$PROJECT_DIR/Flutter/flutter_export_environment.sh"

# Reset Xcode caches completely
defaults delete com.apple.dt.Xcode || true
rm -rf ~/Library/Caches/com.apple.dt.Xcode/* || true
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
rm -rf ~/Library/Developer/Xcode/Archives/*

# Get Flutter packages
cd "$ROOT_DIR"
flutter pub get

# Completely deintegrate and reinstall pods
cd "$PROJECT_DIR"
LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 pod deintegrate || true
LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 pod setup --verbose
LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 pod install --repo-update

# Create necessary directories
mkdir -p ~/Library/Developer/Xcode/DerivedData

echo "Xcode environment cleaned successfully! Restart Xcode completely before building."
echo "If problems persist, try: sudo xcode-select --reset"