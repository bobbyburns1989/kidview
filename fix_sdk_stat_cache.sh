#!/bin/bash
echo "This script needs to be run with sudo to fix Xcode SDK stat cache issues."
echo "For example: sudo ./fix_sdk_stat_cache.sh"
echo ""

if [ "$(id -u)" != "0" ]; then
   echo "⚠️ This script must be run as root (with sudo)" 
   exit 1
fi

echo "🔧 Fixing Xcode SDK Stat Cache permissions..."

# Create the necessary directories with correct permissions
mkdir -p ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex

# Ensure directories exist
touch ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/.keep

# Set permissions to allow read-write access
chmod -R 777 ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex

# Make sure the current user owns these directories
chown -R $(logname):$(id -gn $(logname)) ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex

echo "✅ Fixed Xcode SDK Stat Cache permissions."
echo "Now try running flutter again:"
echo "flutter run"