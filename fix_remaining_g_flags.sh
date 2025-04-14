#!/bin/bash

echo "🔧 Removing all remaining -G flags from Xcode project files..."

# Find all pbxproj files and remove -G flags
find . -name "*.pbxproj" -type f -exec sed -i '' 's/-G / /g' {} \;
find . -name "*.pbxproj" -type f -exec sed -i '' 's/-G[,;]/ /g' {} \;
find . -name "*.pbxproj" -type f -exec sed -i '' 's/ -G / /g' {} \;
find . -name "*.pbxproj" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find . -name "*.pbxproj" -type f -exec sed -i '' 's/-G"/"/g' {} \;

# Find all xcconfig files and remove -G flags
find . -name "*.xcconfig" -type f -exec sed -i '' 's/-G / /g' {} \;
find . -name "*.xcconfig" -type f -exec sed -i '' 's/-G$/ /g' {} \;
find . -name "*.xcconfig" -type f -exec sed -i '' 's/ -G / /g' {} \;
find . -name "*.xcconfig" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find . -name "*.xcconfig" -type f -exec sed -i '' 's/-G"/"/g' {} \;

echo "🧹 Cleaning Flutter cache..."
flutter clean

echo "🗑️ Removing all build artifacts..."
rm -rf build/ ios/Pods/ ios/Podfile.lock ios/.symlinks/ ios/Flutter/Flutter.podspec

echo "📦 Reinstalling dependencies..."
flutter pub get

echo "📱 Setting up iOS project..."
cd ios
pod install
cd ..

echo "✅ All fixes applied. Try running the app now with 'flutter run'"