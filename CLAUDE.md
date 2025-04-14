# KidView Development Guide

## Project Overview
KidView is a safe and educational video platform for children, designed to provide age-appropriate content for children aged 4-12.

## Common Commands

### Development
```bash
# Run the development server
flutter run

# Clean the build artifacts
flutter clean

# Get dependencies
flutter pub get
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Building
```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

### Analysis
```bash
# Run the analyzer
flutter analyze

# Fix common issues
dart fix --apply
```

## Project Structure
- `/lib/config` - Configuration files and app-wide settings
- `/lib/core` - Core utilities and constants
- `/lib/data` - Data models, services, and providers
- `/lib/features` - Feature-based modules (organized by domain)
- `/lib/shared` - Shared components and widgets

## Development Notes
- The app uses Provider pattern for state management
- Navigation is handled with go_router
- The app has two main themes: one for younger kids (4-7) and one for older kids (8-12)
- For demo purposes, the app uses mock data instead of Firebase
- To log in with the demo account, use:
  - Email: demo@example.com
  - Password: password

## ARM Mac Setup
On ARM Macs, you need to install Rosetta 2:
```bash
sudo softwareupdate --install-rosetta --agree-to-license
```