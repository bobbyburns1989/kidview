#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"

echo "🔧 Fixing symbolic links for header files..."

# Create Pods/Headers directory if it doesn't exist
mkdir -p Pods/Headers

# Create symlinks for all header files
find Pods -name "*.h" | while read header; do
  # Get the basename of the header file
  basename=$(basename "$header")
  # Create a symlink in the Pods/Headers directory
  ln -sf "../../$header" "Pods/Headers/$basename" || true
done

# Create symbolic links for specific video_player_avfoundation headers
mkdir -p Pods/Headers/video_player_avfoundation
mkdir -p Pods/Headers/video_player_avfoundation/ios

# Try to find where the headers are
PLUGIN_DIR=$(find ~/.pub-cache -name "video_player_avfoundation-*" -type d | head -n 1)

if [ -n "$PLUGIN_DIR" ]; then
  echo "Found plugin at: $PLUGIN_DIR"
  
  # Create symlinks for headers
  find "$PLUGIN_DIR" -name "*.h" | while read header; do
    basename=$(basename "$header")
    ln -sf "$header" "Pods/Headers/video_player_avfoundation/$basename" || true
  done
fi

# Force update the Pods project to recognize the changes
pod install --no-repo-update

echo "✅ Header symlinks created."
echo "Now try running: flutter run"