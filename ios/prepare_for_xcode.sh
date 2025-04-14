#!/bin/bash

echo "🔨 KidView - Comprehensive Xcode & Flutter Fix Script 🔨"
echo "This script will fix common issues with Xcode and Flutter for this project."
echo ""

# Store username for later use
CURRENT_USER=$(logname || whoami)
PROJECT_PATH="/Users/robertburns/Projects/kidview"

# Check if running as root, if not, suggest sudo
if [ "$(id -u)" != "0" ]; then
   echo "⚠️ This script requires sudo permissions to fix Xcode directories"
   echo "Please run: sudo $0"
   exit 1
fi

# Function to show progress
show_step() {
  echo ""
  echo "🔹 $1"
  echo "----------------------------------------------"
}

# Step 1: Fix Xcode permissions
show_step "Step 1/7: Fixing Xcode permissions"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
mkdir -p ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
mkdir -p ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex
touch ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/Session.modulevalidation
chmod -R 777 ~/Library/Developer/Xcode/DerivedData/
chown -R $CURRENT_USER:staff ~/Library/Developer/Xcode/DerivedData/

# Step 2: Clean Xcode caches
show_step "Step 2/7: Cleaning Xcode caches"
rm -rf /Users/$CURRENT_USER/Library/Caches/com.apple.dt.Xcode/*
defaults delete com.apple.dt.Xcode || true
killall -9 Xcode || true

# Step 3: Fix Flutter dependencies (run as the regular user)
show_step "Step 3/7: Fixing Flutter dependencies"
cd "$PROJECT_PATH"
sudo -u $CURRENT_USER flutter clean
sudo -u $CURRENT_USER rm -f pubspec.lock

# Step 4: Downgrade video_player if needed
show_step "Step 4/7: Setting video_player to stable version"
if grep -q "video_player:" pubspec.yaml; then
  sudo -u $CURRENT_USER cp pubspec.yaml pubspec.yaml.backup
  sudo -u $CURRENT_USER sed -i '' 's/video_player:.*/video_player: 2.7.0/g' pubspec.yaml
  echo "✅ Modified pubspec.yaml to use video_player 2.7.0"
fi

# Step 5: Get Flutter dependencies
show_step "Step 5/7: Getting Flutter dependencies"
sudo -u $CURRENT_USER flutter pub get

# Step 6: Set up iOS project
show_step "Step 6/7: Setting up iOS project"
cd "$PROJECT_PATH/ios"
sudo -u $CURRENT_USER rm -rf Pods
sudo -u $CURRENT_USER rm -f Podfile.lock
sudo -u $CURRENT_USER pod deintegrate || true
sudo -u $CURRENT_USER pod cache clean --all
sudo -u $CURRENT_USER pod install --repo-update

# Step 7: Fix symlinks for header files
show_step "Step 7/7: Creating symlinks for header files"
mkdir -p Pods/Headers
find Pods -name "*.h" 2>/dev/null | while read header; do
  basename=$(basename "$header")
  ln -sf "../../$header" "Pods/Headers/$basename" || true
done

echo ""
echo "✅ All fixes have been applied successfully!"
echo ""
echo "You can now open the project in Xcode with:"
echo "open $PROJECT_PATH/ios/Runner.xcworkspace"
echo ""
echo "Or run the app directly with:"
echo "flutter run"
echo ""
echo "If you encounter any issues when archiving for TestFlight, run:"
echo "cd ios && ./prepare_for_testflight.sh"

# Set proper ownership for any created files
chown -R $CURRENT_USER:staff "$PROJECT_PATH"

# Ask if the user wants to open Xcode
read -p "Would you like to open the project in Xcode now? (y/n) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  sudo -u $CURRENT_USER open "$PROJECT_PATH/ios/Runner.xcworkspace"
fi