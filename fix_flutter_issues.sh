#!/bin/bash
set -e

# Print commands being executed
set -x

echo "🔧 Fixing Flutter run issues..."

# Step 1: Clean Flutter completely
echo "🧹 Cleaning Flutter..."
flutter clean
flutter pub cache clean

# Step 2: Delete problematic directories
echo "🗑️ Removing problematic directories..."
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Step 3: Ensure .pub-cache permissions are correct
echo "🔧 Fixing pub cache permissions..."
if [ -d "$HOME/.pub-cache" ]; then
  chmod -R +w "$HOME/.pub-cache"
fi

# Step 4: Fix iOS-specific issues
echo "🔧 Fixing iOS-specific issues..."
if [ -d "ios" ]; then
  cd ios
  rm -rf Pods
  rm -rf .symlinks
  rm -f Podfile.lock
  rm -f Flutter/Flutter.podspec
  cd ..
fi

# Step 5: Reinstall Flutter dependencies
echo "📦 Reinstalling Flutter dependencies..."
flutter pub get

# Step 6: Repair Flutter
echo "🔧 Repairing Flutter installation..."
flutter doctor --verbose
flutter pub cache repair

# Step 7: If iOS platform, reinstall pods
if [ -d "ios" ]; then
  echo "📦 Reinstalling CocoaPods..."
  cd ios
  pod deintegrate || true
  pod cache clean --all
  pod install --repo-update
  cd ..
fi

# Step 8: Generate needed files
echo "🔧 Generating needed files..."
flutter pub run build_runner build --delete-conflicting-outputs || echo "No build_runner dependency found, skipping."

echo "✅ Flutter issues should be fixed."
echo "Now try running the app again with: flutter run"

# Ask if the user wants to run the app now
read -p "Would you like to run the app now? (y/n) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  flutter run
fi