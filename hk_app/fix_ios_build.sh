#!/bin/bash
set -e

echo "Starting iOS build fix..."

# Navigate to iOS directory
cd ios

echo "Cleaning up Pods and Lockfiles..."
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.podspec

echo "Flutter Clean..."
cd ..
flutter clean
flutter pub get

echo "Pod Install..."
cd ios
# Check if pod is installed
if ! command -v pod &> /dev/null; then
    echo "CocoaPods not found. Installing..."
    sudo gem install cocoapods
fi

# Try standard pod install
pod install --repo-update

echo "Fix Complete!"
echo "IMPORTANT: Please ensure you open 'ios/Runner.xcworkspace' in Xcode, NOT 'ios/Runner.xcodeproj'."
