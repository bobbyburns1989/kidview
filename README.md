# KidView

KidView is a safe and educational video platform for children, designed to provide age-appropriate content for children aged 4-12.

## Features

- **Child Profiles**: Create and manage personalized profiles for each child with custom settings
- **Age-Appropriate Content**: Two distinct UI themes for younger (4-7) and older (8-12) children
- **Parental Controls**: Screen time limits, content filtering, and PIN protection
- **Content Recommendations**: Personalized recommendations based on viewing history and interests
- **Analytics Dashboard**: Detailed metrics on usage patterns, learning styles, and content engagement
- **Safe Environment**: Carefully curated content library with educational focus

## Getting Started

```bash
# Clone the repository
git clone https://github.com/bobbyburns1989/kidview.git

# Navigate to the project directory
cd kidview

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Development

```bash
# Run the development server
flutter run

# Clean the build artifacts
flutter clean

# Get dependencies
flutter pub get
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Building

```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## Enhanced Analytics Dashboard

The analytics dashboard provides detailed insights on children's viewing habits:

- **Usage Metrics**: Track screen time, daily averages, and usage patterns
- **Content Distribution**: Visualize content category breakdown with engagement ratings
- **Learning Patterns**: Identify preferred learning styles and optimal viewing times
- **Recommendations**: Receive personalized content recommendations
- **Consistency Score**: Measure adherence to screen time limits
- **Balance Score**: Evaluate content diversity across categories

## TestFlight Submission

To prepare and submit the app to TestFlight:

1. Ensure all privacy descriptions are set in Info.plist
2. Run the automated preparation script:
   ```bash
   cd ios
   ./prepare_for_testflight.sh
   ```
3. Follow the on-screen instructions to complete the submission process

## Demo Access

For demo purposes, the app uses mock data instead of Firebase:
- Email: demo@example.com
- Password: password

## License

This project is licensed under the MIT License - see the LICENSE file for details.
