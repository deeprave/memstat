#!/bin/bash

# Build MemStat without code signing for local development
echo "Building MemStat without code signing..."

xcodebuild -project MemStat.xcodeproj \
           -scheme MemStat \
           -configuration Debug \
           CODE_SIGN_IDENTITY=- \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=NO \
           build

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "App location: $(xcodebuild -showBuildSettings -project MemStat.xcodeproj -scheme MemStat -configuration Debug | grep BUILT_PRODUCTS_DIR | head -1 | cut -d'=' -f2 | tr -d ' ')/MemStat.app"
else
    echo "Build failed!"
    exit 1
fi