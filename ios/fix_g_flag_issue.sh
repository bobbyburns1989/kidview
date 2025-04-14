#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"

echo "Fixing -G flag issue in Pods project..."

# Check if Pods project exists
if [ -f "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj" ]; then
  # Backup the project file
  cp -f "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj" "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj.backup"
  
  # Remove -G flag from OTHER_CFLAGS and OTHER_CPLUSPLUSFLAGS
  sed -i '' 's/-G / /g' "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj"
  sed -i '' 's/-G[,;]/ /g' "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj"
  sed -i '' 's/ -G / /g' "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj"
  sed -i '' 's/ -G$/ /g' "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj"
  sed -i '' 's/-G"/"/g' "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj"
  
  # Fix architecture issues for Apple Silicon
  sed -i '' 's/EXCLUDED_ARCHS\[sdk=iphonesimulator\*\].*= .*arm64.*/EXCLUDED_ARCHS\[sdk=iphonesimulator\*\] = i386/g' "$PROJECT_DIR/Pods/Pods.xcodeproj/project.pbxproj"
  
  echo "Fixed Pods project"
fi

# Also fix the Runner project
if [ -f "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj" ]; then
  # Backup the project file
  cp -f "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj" "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj.backup"
  
  # Remove -G flag from OTHER_CFLAGS and OTHER_CPLUSPLUSFLAGS
  sed -i '' 's/-G / /g' "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj"
  sed -i '' 's/-G[,;]/ /g' "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj"
  sed -i '' 's/ -G / /g' "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj"
  sed -i '' 's/ -G$/ /g' "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj"
  sed -i '' 's/-G"/"/g' "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj"
  
  # Fix architecture issues for Apple Silicon
  sed -i '' 's/EXCLUDED_ARCHS\[sdk=iphonesimulator\*\].*= .*arm64.*/EXCLUDED_ARCHS\[sdk=iphonesimulator\*\] = i386/g' "$PROJECT_DIR/Runner.xcodeproj/project.pbxproj"
  
  echo "Fixed Runner project"
fi

# Fix -G flag in all xcconfig files
echo "Fixing -G flag in xcconfig files..."
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G / /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/ -G / /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find "$PROJECT_DIR" -name "*.xcconfig" -type f -exec sed -i '' 's/-G"/"/g' {} \;
echo "Fixed xcconfig files"

echo "All fixes applied. Try building the app now."