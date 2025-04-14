#!/bin/bash
set -e

# Print commands being executed
set -x

# First ensure we're in the iOS directory
cd "$(dirname "$0")"
PROJECT_DIR="$PWD"
cd ..
ROOT_DIR="$PWD"

echo "🔧 Fixing TestFlight archive issues..."

# Step 1: Clean Xcode's DerivedData completely
echo "🧹 Cleaning Xcode's DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# Step 2: Create required directories for ModuleCache
echo "📁 Creating required directories..."
mkdir -p ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
mkdir -p ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex
# Create an empty session validation file to prevent some errors
touch ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/Session.modulevalidation

# Step 3: Completely clean Flutter and CocoaPods cache
echo "🧹 Cleaning Flutter and CocoaPods cache..."
cd "$ROOT_DIR"
flutter clean
flutter pub cache clean

cd "$PROJECT_DIR"
rm -rf ./Pods
rm -rf ./Flutter/Flutter.podspec
rm -rf ./.symlinks
rm -f ./Podfile.lock

# Step 4: Specifically remove problematic plugin cache
echo "🔧 Fixing video_player_avfoundation issues..."
flutter pub cache repair

# Step 5: Remove the Runner.xcworkspace
echo "🗑️ Removing xcworkspace..."
rm -rf Runner.xcworkspace

# Step 6: Reinstall Flutter dependencies
echo "📦 Reinstalling Flutter dependencies..."
cd "$ROOT_DIR"
flutter pub get

# Step 7: Reinstall CocoaPods with verbose output for debugging
echo "📦 Reinstalling CocoaPods..."
cd "$PROJECT_DIR"
pod deintegrate || true
pod cache clean --all
pod repo update
pod install --verbose

# Step 8: Fix script phases in Xcode project
echo "🔧 Fixing script phases in Pods project..."
cd "$PROJECT_DIR"

cat > fix_script_phases.rb << 'EOF'
#!/usr/bin/env ruby
require 'xcodeproj'

def fix_script_phase(phase)
  if phase.name.include?('Create Symlinks to Header Folders') && phase.output_paths.empty?
    puts "Fixing script phase: #{phase.name}"
    # Add some output paths to prevent the warning
    phase.output_paths = ['$(DERIVED_FILE_DIR)/$(PRODUCT_MODULE_NAME)-Swift.h']
    # Or you can turn off dependency analysis
    phase.always_out_of_date = true
  end
end

project_path = 'Pods/Pods.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "Opening project: #{project_path}"

# Process all targets
project.targets.each do |target|
  puts "Examining target: #{target.name}"
  
  # Check all script build phases
  target.build_phases.each do |phase|
    if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
      fix_script_phase(phase)
    end
  end
end

# Save the project
project.save
puts "Project saved with fixed script phases."
EOF

# Make the script executable
chmod +x fix_script_phases.rb

# Check if Ruby is available
if command -v ruby >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
  # Install xcodeproj if needed
  gem list -i xcodeproj || gem install xcodeproj
  # Run the script
  ruby fix_script_phases.rb
else
  echo "Ruby or RubyGems not available. Skipping script phase fixes."
  echo "You'll need to manually fix build phase warnings in Xcode."
fi

# Step 9: Add .gitkeep files to ensure directories exist
mkdir -p ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
touch ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/.gitkeep

mkdir -p ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex
touch ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/.gitkeep

echo "✅ TestFlight archive issues should be fixed."
echo "Now try the following steps:"
echo "1. Open the project in Xcode: open Runner.xcworkspace"
echo "2. Clean the build folder in Xcode: Product > Clean Build Folder"
echo "3. Archive the project again: Product > Archive"
echo ""
echo "If issues persist, try completely restarting Xcode and your Mac."

# Ask if the user wants to open Xcode
read -p "Would you like to open Xcode now? (y/n) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  open "$PROJECT_DIR/Runner.xcworkspace"
fi