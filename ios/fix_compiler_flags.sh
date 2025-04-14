#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"

echo "Searching for Xcode build settings files with -G flag issue..."

# Find all .xcconfig files and fix them
find "$PROJECT_DIR/Pods" -name "*.xcconfig" -type f | xargs grep -l "\-G" | while read -r file; do
  echo "Fixing -G flag in $file"
  sed -i.bak 's/-G / /g' "$file"
  sed -i.bak 's/-G$/ /g' "$file"
  rm -f "${file}.bak"
done

# Also check .pbxproj files
find "$PROJECT_DIR" -name "*.pbxproj" -type f | xargs grep -l "\-G" | while read -r file; do
  echo "Fixing -G flag in $file"
  sed -i.bak 's/-G / /g' "$file"
  sed -i.bak 's/-G$/ /g' "$file"
  sed -i.bak 's/-G[,;]/ /g' "$file"
  rm -f "${file}.bak"
done

echo "Fixing architecture settings for ARM64 simulator..."
find "$PROJECT_DIR/Pods" -name "*.xcconfig" -type f | xargs grep -l "EXCLUDED_ARCHS.*arm64" | while read -r file; do
  echo "Updating excluded architectures in $file"
  sed -i.bak 's/EXCLUDED_ARCHS\[sdk=iphonesimulator\*\].*= arm64/EXCLUDED_ARCHS\[sdk=iphonesimulator\*\] = i386/g' "$file"
  rm -f "${file}.bak"
done

echo "All -G compiler flags have been removed. Try building again."