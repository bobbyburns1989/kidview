# Step-by-Step Guide for TestFlight Submission

## Preparation
Follow these steps carefully to prepare your KidView app for TestFlight submission:

### 1. Clean the environment
```bash
# From the project root
flutter clean

# Clean specific iOS artifacts
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
```

### 2. Get dependencies
```bash
# From the project root
flutter pub get
```

### 3. Install Pods with the updated Podfile
```bash
# From the ios directory
cd ios
pod install --repo-update
```

### 4. Build for TestFlight
```bash
# From the project root
flutter build ios --release --no-codesign
```

## Submit to TestFlight

### 1. Open Xcode
```bash
# From the ios directory
open Runner.xcworkspace
```

### 2. Configure Signing & Capabilities
1. In Xcode, select the "Runner" project in the left sidebar
2. Go to the "Signing & Capabilities" tab
3. Ensure your Apple Developer account is selected
4. Choose your Team
5. Make sure you have a valid Bundle Identifier (e.g., "com.yourcompany.kidview")
6. Verify that "Automatically manage signing" is checked

### 3. Create an Archive
1. In Xcode, select "Any iOS Device (arm64)" as the build target (not a simulator)
2. From the top menu, select Product > Archive
3. Wait for the archiving process to complete

### 4. Submit to TestFlight
1. When archive is complete, the Organizer window will open
2. Select your newest archive
3. Click "Distribute App"
4. Choose "App Store Connect" and click "Next"
5. Select "Upload" and click "Next"
6. Leave all distribution options as default and click "Next"
7. Select your appropriate certificate for distribution and click "Next"
8. Click "Upload" to submit to App Store Connect

### 5. Verify in App Store Connect
1. Log in to App Store Connect (https://appstoreconnect.apple.com/)
2. Go to "Apps" and select your app
3. Go to the "TestFlight" tab
4. Once processing is complete, your build will be available for internal testing
5. You can then add external testers or test groups

## Troubleshooting

If you encounter issues:

### Pod install problems
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install --repo-update
```

### Archive fails due to code signing
Ensure your provisioning profiles are correctly set up in the Apple Developer Portal and imported to Xcode.

### Xcode build errors
Check the error message in the Xcode logs. Common issues include:
- Missing privacy descriptions in Info.plist
- Incompatible pod versions
- Code signing errors

### TestFlight submission rejected
Common reasons for rejection:
- Missing app icon sizes
- Missing privacy policy URL in App Store Connect
- Missing required privacy descriptions
- App crashes during launch