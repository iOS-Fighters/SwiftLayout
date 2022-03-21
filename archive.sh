echo "Cleaning..."
rm -rf ./build
rm -rf ./Binary

echo "Create xcodeproj"
swift package generate-xcodeproj

echo "Archiving..."
xcodebuild archive -scheme SwiftLayout-Package -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination generic/platform=iOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme SwiftLayout-Package  -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "Create XCFramework"
xcodebuild -create-xcframework \
-framework "./build/ios.xcarchive/Products/Library/Frameworks/SwiftLayout.framework" \
-framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/SwiftLayout.framework" \
-output "./Binary/SwiftLayout.xcframework"

rm -rf ./SwiftLayout.xcodeproj

echo "Cleaning..."
rm -rf ./build
