#!/bin/bash

# Script to code sign the MemStat app for distribution

set -e  # Exit on error

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Configuration
APP_NAME="MemStat"
BUILD_DIR="${PROJECT_DIR}/build/Build/Products/Release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"

echo "=== ${APP_NAME} Code Signing ==="
echo ""

# Check if app exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App not found at ${APP_PATH}"
    echo "Please build the app in Release configuration first."
    exit 1
fi

# Check for available signing identities
echo "Available signing identities:"
security find-identity -v -p codesigning

echo ""

# Get signing identity from user or environment
if [ -n "$CODESIGN_IDENTITY" ]; then
    SIGNING_IDENTITY="$CODESIGN_IDENTITY"
    echo "Using signing identity from environment: $SIGNING_IDENTITY"
else
    echo "Enter your Developer ID Application certificate name:"
    echo "(e.g., 'Developer ID Application: Your Name (TEAMID)')"
    echo "Or set CODESIGN_IDENTITY environment variable"
    echo ""
    read -p "Signing identity: " SIGNING_IDENTITY
fi

if [ -z "$SIGNING_IDENTITY" ]; then
    echo "Error: No signing identity specified."
    exit 1
fi

echo ""
echo "Signing ${APP_NAME}.app with identity: $SIGNING_IDENTITY"
echo ""

# Sign the app with hardened runtime
echo "Code signing the application..."
codesign --force \
    --options runtime \
    --sign "$SIGNING_IDENTITY" \
    --timestamp \
    "$APP_PATH"

# Verify the signature
echo ""
echo "Verifying code signature..."
codesign --verify --verbose=2 "$APP_PATH"

echo ""
echo "Checking signature details..."
codesign --display --verbose=2 "$APP_PATH"

echo ""
echo "✅ Code signing completed successfully!"
echo ""
echo "The app is now signed and ready for notarization."
echo ""
echo "Next steps for distribution:"
echo "1. Notarize the app with Apple:"
echo "   xcrun notarytool submit \"$APP_PATH\" --keychain-profile \"notarytool-password\""
echo "2. Staple the notarization ticket:"
echo "   xcrun stapler staple \"$APP_PATH\""
echo "3. Create distribution packages (ZIP/DMG)"
echo ""
echo "Note: You'll need to set up an App Store Connect API key"
echo "      or app-specific password for notarization."