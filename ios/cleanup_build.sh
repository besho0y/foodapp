#!/bin/bash
# iOS Build Cleanup Script - Enhanced for build.db issues and network problems

echo "Cleaning up iOS build environment and resolving build.db lock..."

# Kill any running Xcode processes
echo "Stopping Xcode processes..."
pkill -f Xcode
pkill -f xcodebuild
pkill -f xcrun
sleep 2

# Remove all derived data (including the locked build.db)
echo "Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Remove local build artifacts
echo "Removing local build artifacts..."
rm -rf build/
rm -rf ios/build/
rm -rf .dart_tool/flutter_build/

# Remove Pods directory and Podfile.lock
echo "Cleaning CocoaPods..."
rm -rf ios/Pods/
rm -f ios/Podfile.lock

# Clean Flutter
echo "Cleaning Flutter..."
flutter clean

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Clean and reinstall iOS pods with network retry
echo "Reinstalling CocoaPods with network retry..."
cd ios/

# Clear CocoaPods cache
echo "Clearing CocoaPods cache..."
pod cache clean --all

# Remove existing pod setup
pod deintegrate 2>/dev/null || true
pod clean 2>/dev/null || true

# Configure Git for better network handling
echo "Configuring Git for better network handling..."
git config --global http.postBuffer 524288000
git config --global http.maxRequestBuffer 100M
git config --global core.compression 0

# Try pod install with retry mechanism
echo "Installing pods with retry mechanism..."
for i in {1..3}; do
    echo "Pod install attempt $i of 3..."

    # Try with different configurations
    if [ $i -eq 1 ]; then
        echo "Trying standard pod install..."
        pod install --repo-update
    elif [ $i -eq 2 ]; then
        echo "Trying pod install without repo update..."
        pod install
    else
        echo "Trying pod install with verbose output..."
        pod install --verbose
    fi

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "Pod install successful!"
        break
    else
        echo "Pod install failed on attempt $i"
        if [ $i -lt 3 ]; then
            echo "Waiting 10 seconds before retry..."
            sleep 10
            # Clean cache between retries
            pod cache clean --all
        fi
    fi
done

# If all attempts failed, try alternative approach
if [ $? -ne 0 ]; then
    echo "All pod install attempts failed. Trying alternative approach..."

    # Remove Podfile.lock and try again
    rm -f Podfile.lock

    # Try with different source
    echo "Trying with CDN source..."
    pod install --repo-update --verbose
fi

cd ..

# Clear iOS Simulator data (optional, commented out to speed up process)
# echo "Clearing iOS Simulator data..."
# xcrun simctl erase all

echo "iOS build environment cleaned and reset!"

# Check if Pods directory exists to verify success
if [ -d "ios/Pods" ]; then
    echo "✅ CocoaPods installation successful!"
    echo "You can now try building again with 'flutter run' or opening in Xcode"
else
    echo "⚠️  CocoaPods installation may have failed."
    echo "Try the following manual steps:"
    echo "1. Check your internet connection"
    echo "2. Try: cd ios && pod install --repo-update"
    echo "3. If still failing, try: cd ios && pod install --verbose"
    echo "4. Consider using a VPN if you're in a restricted network"
fi