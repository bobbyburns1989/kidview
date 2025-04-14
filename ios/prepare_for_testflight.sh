#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"
cd ..
ROOT_DIR="$PWD"

echo "🧹 Cleaning up previous builds..."
cd "$ROOT_DIR"
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔧 Cleaning Xcode cache and reinstalling pods..."
cd "$PROJECT_DIR"
rm -rf Pods Podfile.lock ./Flutter/Flutter.podspec
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/* 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/* 2>/dev/null || true

# Create necessary directories if missing
mkdir -p ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
mkdir -p ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex

# Fix compiler flags in Run Script phase to avoid Xcode issues
if [ -f "$PROJECT_DIR/fix_compiler_flags.sh" ]; then
  echo "🔄 Running fix_compiler_flags.sh..."
  bash "$PROJECT_DIR/fix_compiler_flags.sh"
fi

# Fix g flag issues in certain configurations
if [ -f "$PROJECT_DIR/fix_g_flag_issue.sh" ]; then
  echo "🔄 Running fix_g_flag_issue.sh..."
  bash "$PROJECT_DIR/fix_g_flag_issue.sh"
fi

# Reinstall pods with cache bust
echo "🔄 Installing pods..."
LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 pod deintegrate || true
LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 pod install --repo-update

echo "📱 Building iOS app for TestFlight..."
cd "$ROOT_DIR"
flutter build ios --release --no-codesign --no-tree-shake-icons

# Verify Info.plist has all required privacy descriptions
echo "🔍 Verifying Info.plist privacy descriptions..."
required_keys=(
  "NSCameraUsageDescription"
  "NSPhotoLibraryUsageDescription"
  "NSMicrophoneUsageDescription"
  "NSUserTrackingUsageDescription"
  "NSLocationWhenInUseUsageDescription"
  "NSMotionUsageDescription"
  "NSBluetoothAlwaysUsageDescription"
)

missing_keys=()
for key in "${required_keys[@]}"; do
  if ! grep -q "<key>$key</key>" "$PROJECT_DIR/Runner/Info.plist"; then
    missing_keys+=("$key")
  fi
done

if [ ${#missing_keys[@]} -gt 0 ]; then
  echo "⚠️ Warning: Missing required privacy descriptions in Info.plist:"
  for key in "${missing_keys[@]}"; do
    echo "  - $key"
  done
  echo "Please add these descriptions to Info.plist before submitting to TestFlight"
else
  echo "✅ All required privacy descriptions found in Info.plist"
fi

# Verify app icons are included
echo "🔍 Verifying app icons..."
if [ ! -f "$PROJECT_DIR/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" ]; then
  echo "⚠️ Warning: App icon missing (1024x1024). App will be rejected without this icon."
else
  echo "✅ App icon found (1024x1024)"
fi

echo "✅ Build completed successfully!"
echo ""
echo "Now open Runner.xcworkspace in Xcode and submit to TestFlight:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. In Xcode, select 'Any iOS Device' as the build target"
echo "3. Go to Product > Archive"
echo "4. In the Archives window, click 'Distribute App'"
echo "5. Select 'App Store Connect' and then 'Upload'"
echo "6. Follow the on-screen instructions to complete the upload"
echo "7. Check App Store Connect for the build status"
echo ""
echo "If you want to automate the archive and upload process, run:"
echo "xcodebuild -workspace Runner.xcworkspace -scheme Runner -config Release archive -archivePath /path/to/archive.xcarchive"
echo "xcodebuild -exportArchive -archivePath /path/to/archive.xcarchive -exportOptionsPlist exportOptions.plist -exportPath /path/to/export"
echo ""

# Ask if the user wants to open Xcode
read -p "Would you like to open Xcode now? (y/n) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  open "$PROJECT_DIR/Runner.xcworkspace"
fi