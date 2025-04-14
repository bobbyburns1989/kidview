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
rm -f pubspec.lock
flutter pub get

echo "🔧 Cleaning Xcode cache and reinstalling pods..."
cd "$PROJECT_DIR"
rm -rf Pods Podfile.lock ./Flutter/Flutter.podspec
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true

# Fix compiler flags in Run Script phase to avoid Xcode issues
if [ -f "$PROJECT_DIR/fix_compiler_flags.sh" ]; then
  echo "🔄 Running fix_compiler_flags.sh..."
  bash "$PROJECT_DIR/fix_compiler_flags.sh"
fi

# Fix G flag issues in project files and xcconfig files
echo "🔄 Fixing -G flag issues..."
# Remove -G flag from xcconfig files
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G / /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/ -G / /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G"/"/g' {} \;

# Install pods
echo "🔄 Installing pods..."
pod install --repo-update

# Fix G flag issues in all generated files
echo "🔄 Fixing -G flag in generated files..."
find "$PROJECT_DIR" -name "*.pbxproj" -type f -exec sed -i '' 's/-G / /g' {} \;
find "$PROJECT_DIR" -name "*.pbxproj" -type f -exec sed -i '' 's/-G[,;]/ /g' {} \;
find "$PROJECT_DIR" -name "*.pbxproj" -type f -exec sed -i '' 's/ -G / /g' {} \;
find "$PROJECT_DIR" -name "*.pbxproj" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.pbxproj" -type f -exec sed -i '' 's/-G"/"/g' {} \;

# Fix any remaining xcconfig files that might have been generated
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G / /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/ -G / /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G"/"/g' {} \;

echo "📱 Building iOS app for TestFlight..."
cd "$ROOT_DIR"
flutter build ios --release --no-codesign --no-tree-shake-icons

echo "✅ All fixes applied and build completed!"
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

# Ask if the user wants to open Xcode
read -p "Would you like to open Xcode now? (y/n) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  open "$PROJECT_DIR/Runner.xcworkspace"
fi