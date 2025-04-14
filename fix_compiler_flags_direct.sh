#!/bin/bash

echo "🔧 Direct fix for compiler flags..."

PBXPROJ_PATH="ios/Pods/Pods.xcodeproj/project.pbxproj"

if [ -f "$PBXPROJ_PATH" ]; then
  echo "🔧 Fixing compiler flags in $PBXPROJ_PATH..."
  
  # Create a backup
  cp "$PBXPROJ_PATH" "${PBXPROJ_PATH}.bak"
  
  # Replace the problematic compiler flags
  perl -i -pe 's/(COMPILER_FLAGS = ".*)-GCC_WARN_INHIBIT_ALL_WARNINGS/$1-Wno-everything/g' "$PBXPROJ_PATH"
  
  echo "✅ Fixed compiler flags"
else
  echo "❌ Could not find $PBXPROJ_PATH"
  exit 1
fi

echo "✅ Now try running your app with:"
echo "flutter run -d 00008120-000659523CC3601E"