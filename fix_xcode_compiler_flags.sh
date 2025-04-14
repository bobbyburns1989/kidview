#!/bin/bash

# This script specifically fixes compiler flag issues in Xcode projects
# It directly modifies the project.pbxproj files to remove problematic flags

echo "🔧 Looking for Xcode project files..."

# Find all project.pbxproj files in the iOS directory
ios_project_files=$(find ios -name "project.pbxproj")

echo "📄 Found $(echo "$ios_project_files" | wc -l | tr -d ' ') Xcode project files"

for proj_file in $ios_project_files; do
  echo "🛠️ Processing $proj_file"
  
  # Create backup of the original file
  cp "$proj_file" "${proj_file}.backup"
  
  # Check if file contains -G flags
  if grep -q '\-G' "$proj_file"; then
    echo "  ⚠️ Found -G flags in $proj_file"
    
    # Replace all variations of -G flags
    perl -pi -e 's/\-G[ ,;"]/\1/g' "$proj_file"
    perl -pi -e 's/[ "]\-G[ ,;"]/\1/g' "$proj_file"
    perl -pi -e 's/[ "]\-G$/\1/g' "$proj_file"
    
    echo "  ✅ Removed -G flags from $proj_file"
  else
    echo "  ✅ No -G flags found in $proj_file"
  fi
  
  # Also fix OTHER_CFLAGS and OTHER_CPLUSPLUSFLAGS with -G flags
  perl -pi -e 's/(OTHER_CFLAGS|OTHER_CPLUSPLUSFLAGS)[ ]*=[ ]*".*?\-G.*?"/$1 = ""/g' "$proj_file"
  
  echo "  ✅ Fixed compiler flag settings in $proj_file"
done

echo "🔧 Fixing Xcode configuration files..."

# Find and fix all xcconfig files
xcconfig_files=$(find ios -name "*.xcconfig")

for config_file in $xcconfig_files; do
  echo "🛠️ Processing $config_file"
  
  # Create backup of the original file
  cp "$config_file" "${config_file}.backup"
  
  # Check if file contains -G flags
  if grep -q '\-G' "$config_file"; then
    echo "  ⚠️ Found -G flags in $config_file"
    
    # Replace all variations of -G flags
    perl -pi -e 's/\-G[ ]/ /g' "$config_file"
    perl -pi -e 's/[ ]\-G[ ]/ /g' "$config_file"
    perl -pi -e 's/[ ]\-G$/ /g' "$config_file"
    perl -pi -e 's/\-G"/"/' "$config_file"
    
    echo "  ✅ Removed -G flags from $config_file"
  else
    echo "  ✅ No -G flags found in $config_file"
  fi
done

echo "🧹 Cleaning Flutter cache..."
flutter clean

echo "📦 Reinstalling dependencies..."
flutter pub get

echo "📱 Setting up iOS project..."
cd ios
pod install
cd ..

echo "✅ All fixes applied. Try running the app now with 'flutter run'"