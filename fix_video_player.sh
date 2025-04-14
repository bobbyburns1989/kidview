#!/bin/bash
set -e

echo "🔧 This script will fix video_player_avfoundation issues by downgrading to a more stable version."

# Directly modify the pubspec.yaml to use an older version of video_player
if grep -q "video_player:" pubspec.yaml; then
  # Backup the original file
  cp pubspec.yaml pubspec.yaml.backup
  
  # Replace video_player dependency with specific version
  sed -i '' 's/video_player:.*/video_player: 2.7.0/g' pubspec.yaml
  
  echo "✅ Modified pubspec.yaml to use video_player 2.7.0"
else
  # Add the dependency if it doesn't exist
  echo "  video_player: 2.7.0" >> pubspec.yaml
  echo "✅ Added video_player 2.7.0 to pubspec.yaml"
fi

# Clean and get dependencies
echo "🧹 Cleaning Flutter project..."
flutter clean

echo "🗑️ Removing pubspec.lock..."
rm -f pubspec.lock

echo "📦 Getting dependencies..."
flutter pub get

# Handle iOS specific setup
if [ -d "ios" ]; then
  echo "📱 Setting up iOS project..."
  cd ios
  
  # Clean CocoaPods
  rm -rf Pods
  rm -f Podfile.lock
  
  # Install pods
  echo "📦 Installing pods..."
  pod install
  
  cd ..
fi

echo "✅ Setup complete."
echo ""
echo "IMPORTANT: Now you need to fix permissions in Xcode directories. Run:"
echo "sudo ./fix_xcode_permissions.sh"
echo ""
echo "After that, you should be able to run the app with:"
echo "flutter run"