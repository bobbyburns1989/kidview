#!/bin/bash

echo "🔧 Comprehensive fix for iOS build issues..."

# Clean the project
echo "🧹 Cleaning Flutter project..."
flutter clean

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Only clean Pod artifacts, but leave Flutter config files
echo "🧹 Cleaning iOS build artifacts..."
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks

# Update the Podfile to remove all -G flags properly
echo "📝 Creating a better Podfile..."
cat > ios/Podfile << 'EOF'
# Uncomment this line to define a global platform for your project
platform :ios, '14.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Suppress warning about master specs repo
install! 'cocoapods', 
  :warn_for_unused_master_specs_repo => false,
  :deterministic_uuids => false

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  # Flutter-specific additional iOS build settings
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
  
  # Apply to all targets in the project
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Ensure minimum iOS version is set properly
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      
      # Required for TestFlight builds
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      
      # Fix to support Xcode 15 and new build process
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
      
      # Remove the problematic EXCLUDED_ARCHS settings
      if config.name == 'Debug'
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "i386"
      end
      
      # Replace problematic flags - CRITICAL FIX
      if ['BoringSSL-GRPC', 'gRPC-Core', 'gRPC-C++', 'abseil'].include?(target.name)
        # Get all compiler flags
        compiler_flags = config.build_settings['OTHER_CFLAGS'] || ""
        cxx_flags = config.build_settings['OTHER_CPLUSPLUSFLAGS'] || ""
        
        # Replace -G in compiler flags with an empty string
        compiler_flags = compiler_flags.gsub(/-G\b/, '')
        cxx_flags = cxx_flags.gsub(/-G\b/, '')
        
        # Update the replaced flags
        config.build_settings['OTHER_CFLAGS'] = compiler_flags
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] = cxx_flags
      end
    end
  end
end
EOF

# Install pods
echo "📦 Installing pod dependencies..."
cd ios
pod install

# After pod install, we need to directly edit the project.pbxproj file
# to replace problematic compiler flags in file build settings
PBXPROJ_PATH="Pods/Pods.xcodeproj/project.pbxproj"
if [ -f "$PBXPROJ_PATH" ]; then
  echo "🔧 Directly editing $PBXPROJ_PATH to fix compiler flags..."
  
  # Create a backup first
  cp "$PBXPROJ_PATH" "${PBXPROJ_PATH}.bak"
  
  # Fix compiler flags with -G in them
  perl -i -pe 's/(-G\b|"-G"|" -G "| -G$)/ /g' "$PBXPROJ_PATH"
  
  # Specifically replace -GCC_WARN_INHIBIT_ALL_WARNINGS with -Wno-everything
  perl -i -pe 's/-GCC_WARN_INHIBIT_ALL_WARNINGS/-Wno-everything/g' "$PBXPROJ_PATH"
  
  echo "✅ Fixed compiler flags in Xcode project"
else
  echo "❌ Could not find $PBXPROJ_PATH"
  exit 1
fi

cd ..

echo "✅ All fixes applied. Now try running your app with:"
echo "flutter run -d 00008120-000659523CC3601E"