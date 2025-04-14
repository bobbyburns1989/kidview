#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"
cd ..
ROOT_DIR="$PWD"

echo "🔧 Fixing video_player_avfoundation issues..."

# Step 1: Remove video_player from pubspec.lock to force re-download
echo "🗑️ Removing video_player from lock file..."
cd "$ROOT_DIR"
if [ -f "pubspec.lock" ]; then
  grep -v "video_player" pubspec.lock > pubspec.lock.new
  mv pubspec.lock.new pubspec.lock
fi

# Step 2: Clean pub cache for video_player
echo "🧹 Cleaning video_player from pub cache..."
flutter pub cache clean

# Step 3: Specifically remove video_player_avfoundation cache files
echo "🗑️ Removing video_player_avfoundation cache files..."
rm -rf ~/.pub-cache/hosted/pub.dev/video_player_avfoundation-*

# Step 4: Remove pod cache for video_player
echo "🧹 Cleaning video_player from pod cache..."
cd "$PROJECT_DIR"
pod cache clean video_player_avfoundation || true

# Step 5: Get dependencies again
echo "📦 Reinstalling dependencies..."
cd "$ROOT_DIR"
flutter pub get

# Step 6: Set up symlinks to ensure headers are found
echo "🔧 Setting up symlinks for header files..."
cd "$PROJECT_DIR"
mkdir -p Pods/Headers
find . -name "*.h" -exec ln -sf {} Pods/Headers/ \; 2>/dev/null || true

# Step 7: Reinstall pods
echo "📦 Reinstalling pods..."
pod deintegrate || true
pod cache clean --all
pod install --repo-update

echo "✅ video_player_avfoundation issues should be fixed."
echo "Now try archiving your app in Xcode again."

# Ask if the user wants to open Xcode
read -p "Would you like to open Xcode now? (y/n) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  open "$PROJECT_DIR/Runner.xcworkspace"
fi