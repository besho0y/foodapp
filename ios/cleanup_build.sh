#!/bin/bash
# iOS Build Cleanup Script

echo "Cleaning up iOS build environment..."

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Remove Pods directory and Podfile.lock
rm -rf ios/Pods/
rm -f ios/Podfile.lock

# Clean Flutter
flutter clean

# Get Flutter dependencies
flutter pub get

# Clean and reinstall iOS pods
cd ios/
pod deintegrate
pod clean
pod install
cd ..

echo "iOS build environment cleaned and reset!" 