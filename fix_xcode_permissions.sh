#!/bin/bash
echo "This script needs to be run with sudo to fix Xcode permission issues."
echo "For example: sudo ./fix_xcode_permissions.sh"
echo ""

if [ "$(id -u)" != "0" ]; then
   echo "⚠️ This script must be run as root (with sudo)" 
   exit 1
fi

echo "🔧 Fixing Xcode DerivedData permissions..."

# Remove problematic directories
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Create the necessary directories with correct permissions
mkdir -p ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
mkdir -p ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex

# Set permissions to allow read-write access
chmod -R 777 ~/Library/Developer/Xcode/DerivedData/
chmod -R 777 ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
chmod -R 777 ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex

# Make sure the current user owns these directories
chown -R $(logname):$(id -gn $(logname)) ~/Library/Developer/Xcode/DerivedData/

echo "✅ Fixed Xcode DerivedData permissions."
echo "Now run: flutter clean && flutter pub get && cd ios && pod install"