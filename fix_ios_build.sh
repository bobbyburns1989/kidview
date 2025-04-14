#!/bin/bash

echo "🔧 Comprehensive iOS build fix script"
echo "------------------------------------"

# Clean up previous build artifacts
echo "🧹 Cleaning Flutter project..."
flutter clean

# Remove existing Flutter-related directories in iOS
echo "🗑️ Removing Flutter build directories..."
rm -rf ios/Flutter/Flutter.podspec ios/.symlinks ios/Flutter/Generated.xcconfig ios/Flutter/flutter_export_environment.sh

# Remove Pods
echo "🗑️ Removing Pod dependencies..."
rm -rf ios/Pods ios/Podfile.lock

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Fix Podfile to handle the -G compiler flag issue
echo "🔧 Updating Podfile to fix compiler flags..."
cat > ios/Podfile << 'EOF'
# Uncomment this line to define a global platform for your project
platform :ios, '14.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Suppress warning about master specs repo
install! 'cocoapods', 
  :warn_for_unused_master_specs_repo => false,
  :deterministic_uuids => false

# Enable modular headers for all pods
ENV['USE_FRAMEWORKS'] = 'static'

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
      # Ensure minimum iOS version is set properly - TestFlight requires 14.0+ now
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      
      # Required for TestFlight builds
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      
      # Fix to support Xcode 15 and new build process for publishing
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
      
      # Remove the problematic EXCLUDED_ARCHS settings
      # Fix for ARM Mac build issues with Xcode 16+
      if config.name == 'Debug'
        # Don't exclude arm64 for simulator builds on Apple Silicon
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "i386"
      end
      
      # CRITICAL: Fix for the unsupported -G compiler flag
      if config.build_settings["OTHER_CPLUSPLUSFLAGS"].to_s.include?("-G")
        config.build_settings["OTHER_CPLUSPLUSFLAGS"] = config.build_settings["OTHER_CPLUSPLUSFLAGS"].to_s.gsub(/-G\b/, '')
      end

      if config.build_settings["OTHER_CFLAGS"].to_s.include?("-G")
        config.build_settings["OTHER_CFLAGS"] = config.build_settings["OTHER_CFLAGS"].to_s.gsub(/-G\b/, '')
      end
      
      # Required for Firebase
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      
      # Fixes for specific pod targets - mostly dealing with Firebase/gRPC dependencies
      if ['gRPC-Core', 'gRPC-C++', 'BoringSSL-GRPC', 'abseil'].include?(target.name)
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        if config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'].is_a?(String)
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = [config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']]
        end
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'COCOAPODS=1'
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << '_GLIBCXX_USE_CXX11_ABI=1'
        
        # IMPORTANT: Remove any compiler flags with -G
        if config.build_settings["OTHER_CFLAGS"]
          config.build_settings["OTHER_CFLAGS"] = config.build_settings["OTHER_CFLAGS"].to_s.gsub(/-G\b/, '')
        end
        if config.build_settings["OTHER_CPLUSPLUSFLAGS"]
          config.build_settings["OTHER_CPLUSPLUSFLAGS"] = config.build_settings["OTHER_CPLUSPLUSFLAGS"].to_s.gsub(/-G\b/, '')
        end
        
        # Fix for Mac Catalyst builds
        config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15' if target.name.start_with?('gRPC') || target.name.start_with?('BoringSSL-GRPC')
      end
      
      # Required by Apple's new build system
      if config.build_settings['WRAPPER_EXTENSION'] == 'bundle'
        config.build_settings['DEVELOPMENT_TEAM'] = 'VS8295GFH3' # Make sure this matches your team ID
      end
      
      # Enable bitcode (required for some TestFlight submissions)
      config.build_settings['ENABLE_BITCODE'] = 'NO' # Set to YES if you need bitcode
      
      # Recommended for iOS 14+
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO' if config.name != 'Debug'
      
      # Allow insecure http loads for Firebase
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
  
  # Fix for Xcode 16 compatibility - don't exclude arm64 for simulator on Apple Silicon
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "i386"
    
    # CRITICAL: Remove any -G compiler flags directly from project build settings
    if config.build_settings["OTHER_CPLUSPLUSFLAGS"]
      config.build_settings["OTHER_CPLUSPLUSFLAGS"] = config.build_settings["OTHER_CPLUSPLUSFLAGS"].to_s.gsub(/-G\b/, '')
    end
    if config.build_settings["OTHER_CFLAGS"]
      config.build_settings["OTHER_CFLAGS"] = config.build_settings["OTHER_CFLAGS"].to_s.gsub(/-G\b/, '')
    end
  end
  
  # Fix Swift compiler warnings in dependencies
  installer.pods_project.targets.select { |target| target.respond_to?(:product_type) && target.product_type == "com.apple.product-type.bundle" }.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
  
  # CRITICAL: Fix the pbxproj file directly after installation
  system("sed -i '' 's/-G / /g' #{installer.pods_project.path}")
  system("sed -i '' 's/-G[,;]/ /g' #{installer.pods_project.path}")
  system("sed -i '' 's/ -G / /g' #{installer.pods_project.path}")
  system("sed -i '' 's/ -G$/ /g' #{installer.pods_project.path}")
  system("sed -i '' 's/-G"/"/g' #{installer.pods_project.path}")
end
EOF

# Install pods
echo "📱 Installing pod dependencies..."
cd ios
pod install
cd ..

# Make sure the -G flag is removed from any pbxproj files
echo "🔧 Final check for -G flags in project files..."
find ios -name "*.pbxproj" -type f -exec sed -i '' 's/-G / /g' {} \;
find ios -name "*.pbxproj" -type f -exec sed -i '' 's/-G[,;]/ /g' {} \;
find ios -name "*.pbxproj" -type f -exec sed -i '' 's/ -G / /g' {} \;
find ios -name "*.pbxproj" -type f -exec sed -i '' 's/ -G$/ /g' {} \;
find ios -name "*.pbxproj" -type f -exec sed -i '' 's/-G"/"/g' {} \;

echo "✅ All fixes applied. Try running the app now with 'flutter run'"
echo "If you still encounter issues, you may need to open Xcode and directly edit the compiler flags."