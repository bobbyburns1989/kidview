#!/bin/bash

echo "🔧 Direct fix for -G flag in Xcode project..."

# Remove -G flags from Pods.xcodeproj/project.pbxproj
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
  echo "  🔧 Fixing Pods.xcodeproj/project.pbxproj"
  # Backup the file first
  cp "ios/Pods/Pods.xcodeproj/project.pbxproj" "ios/Pods/Pods.xcodeproj/project.pbxproj.bak"
  
  # Replace various -G patterns in the file
  perl -i -pe 's/-G\s/ /g; s/-G[,;]/ /g; s/\s-G\s/ /g; s/\s-G$/ /g; s/-G"/"/g;' "ios/Pods/Pods.xcodeproj/project.pbxproj"
  
  echo "  ✅ Fixed Pods.xcodeproj/project.pbxproj"
else
  echo "  ⚠️ Pods.xcodeproj/project.pbxproj not found"
fi

# Remove -G flags from gRPC-C++.xcconfig files
for xcconfig in $(find ios/Pods -name "gRPC-C++*.xcconfig"); do
  echo "  🔧 Fixing $xcconfig"
  # Backup the file first
  cp "$xcconfig" "$xcconfig.bak"
  
  # Replace various -G patterns in the file
  perl -i -pe 's/-G\s/ /g; s/-G[,;]/ /g; s/\s-G\s/ /g; s/\s-G$/ /g; s/-G"/"/g;' "$xcconfig"
  
  echo "  ✅ Fixed $xcconfig"
done

# Remove -G flags from gRPC-Core.xcconfig files
for xcconfig in $(find ios/Pods -name "gRPC-Core*.xcconfig"); do
  echo "  🔧 Fixing $xcconfig"
  # Backup the file first
  cp "$xcconfig" "$xcconfig.bak"
  
  # Replace various -G patterns in the file
  perl -i -pe 's/-G\s/ /g; s/-G[,;]/ /g; s/\s-G\s/ /g; s/\s-G$/ /g; s/-G"/"/g;' "$xcconfig"
  
  echo "  ✅ Fixed $xcconfig"
done

# Remove -G flags from BoringSSL-GRPC.xcconfig files
for xcconfig in $(find ios/Pods -name "BoringSSL-GRPC*.xcconfig"); do
  echo "  🔧 Fixing $xcconfig"
  # Backup the file first
  cp "$xcconfig" "$xcconfig.bak"
  
  # Replace various -G patterns in the file
  perl -i -pe 's/-G\s/ /g; s/-G[,;]/ /g; s/\s-G\s/ /g; s/\s-G$/ /g; s/-G"/"/g;' "$xcconfig"
  
  echo "  ✅ Fixed $xcconfig"
done

# Remove -G flags from abseil.xcconfig files
for xcconfig in $(find ios/Pods -name "abseil*.xcconfig"); do
  echo "  🔧 Fixing $xcconfig"
  # Backup the file first
  cp "$xcconfig" "$xcconfig.bak"
  
  # Replace various -G patterns in the file
  perl -i -pe 's/-G\s/ /g; s/-G[,;]/ /g; s/\s-G\s/ /g; s/\s-G$/ /g; s/-G"/"/g;' "$xcconfig"
  
  echo "  ✅ Fixed $xcconfig"
done

# Look for OTHER_CFLAGS and OTHER_CPLUSPLUSFLAGS in all xcconfig files
for xcconfig in $(find ios/Pods -name "*.xcconfig"); do
  if grep -q "OTHER_C.*FLAGS" "$xcconfig"; then
    echo "  🔧 Fixing compiler flags in $xcconfig"
    # Backup the file first
    cp "$xcconfig" "$xcconfig.bak"
    
    # Replace -G in OTHER_CFLAGS and OTHER_CPLUSPLUSFLAGS
    perl -i -pe 's/(OTHER_C[A-Z_]*FLAGS\s*=\s*.*)-G\b(.*)/$1$2/g;' "$xcconfig"
    
    echo "  ✅ Fixed compiler flags in $xcconfig"
  fi
done

echo "✅ All fixes applied. Try running 'flutter run' again."