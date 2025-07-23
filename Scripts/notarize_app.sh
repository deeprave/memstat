#!/bin/bash

# Script to notarize the MemStat app with Apple
# Usage: ./notarize_app.sh [--submit]
# Without --submit, only checks if app is ready for notarization

set -e  # Exit on error

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Configuration
APP_NAME="MemStat"
BUILD_DIR="${PROJECT_DIR}/build/Build/Products/Release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"

# Check if submit flag is provided
SUBMIT_TO_APPLE=false
if [[ "$1" == "--submit" ]]; then
    SUBMIT_TO_APPLE=true
fi

echo "=== ${APP_NAME} Notarization ==="
echo ""

# Check if app exists and is signed
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App not found at ${APP_PATH}"
    echo "Please build and code sign the app first."
    exit 1
fi

# Verify the app is signed
if ! codesign --verify "${APP_PATH}" >/dev/null 2>&1; then
    echo "Error: App is not code signed."
    echo "Please run ./Scripts/codesign_app.sh first."
    exit 1
fi

echo "✅ App is properly code signed and ready for notarization."
echo ""

if [ "$SUBMIT_TO_APPLE" = false ]; then
    echo "ℹ️  App is ready for notarization but not submitting to Apple."
    echo ""
    echo "To submit for notarization, run:"
    echo "  ./Scripts/notarize_app.sh --submit"
    echo ""
    echo "Prerequisites for notarization:"
    echo "1. Set up notarization credentials:"
    echo "   xcrun notarytool store-credentials \"notarytool-password\" \\"
    echo "     --apple-id \"your@email.com\" \\"
    echo "     --team-id \"TEAMID\" \\"
    echo "     --password \"app-specific-password\""
    echo ""
    echo "2. Set environment variable:"
    echo "   export NOTARIZE_PROFILE=\"notarytool-password\""
    echo ""
    echo "3. Or set individual credentials:"
    echo "   export NOTARIZE_APPLE_ID=\"your@email.com\""
    echo "   export NOTARIZE_PASSWORD=\"app-specific-password\""
    echo "   export NOTARIZE_TEAM_ID=\"TEAMID\""
    exit 0
fi

echo "Proceeding with notarization submission..."
echo ""

# Get notarization credentials
if [ -n "$NOTARIZE_PROFILE" ]; then
    PROFILE="$NOTARIZE_PROFILE"
    echo "Using notarization profile from environment: $PROFILE"
elif [ -n "$NOTARIZE_APPLE_ID" ] && [ -n "$NOTARIZE_PASSWORD" ] && [ -n "$NOTARIZE_TEAM_ID" ]; then
    echo "Using Apple ID credentials from environment variables"
else
    echo "Error: Notarization credentials not found."
    echo ""
    echo "Please set up credentials first:"
    echo ""
    echo "Option 1: Keychain profile (recommended)"
    echo "  xcrun notarytool store-credentials \"notarytool-password\" \\"
    echo "    --apple-id \"your@email.com\" \\"
    echo "    --team-id \"TEAMID\" \\"
    echo "    --password \"app-specific-password\""
    echo "  export NOTARIZE_PROFILE=\"notarytool-password\""
    echo ""
    echo "Option 2: Environment variables"
    echo "  export NOTARIZE_APPLE_ID=\"your@email.com\""
    echo "  export NOTARIZE_PASSWORD=\"app-specific-password\""
    echo "  export NOTARIZE_TEAM_ID=\"TEAMID\""
    exit 1
fi

# Create ZIP for notarization (required format)
NOTARIZE_ZIP="${BUILD_DIR}/${APP_NAME}-notarize.zip"
echo "Creating ZIP for notarization..."
cd "${BUILD_DIR}"
ditto -c -k --keepParent "${APP_NAME}.app" "${APP_NAME}-notarize.zip"

echo ""
echo "Submitting to Apple for notarization..."
echo "This may take several minutes..."

# Submit for notarization
if [ -n "$PROFILE" ]; then
    # Use keychain profile
    echo "Submitting with keychain profile..."
    xcrun notarytool submit "${NOTARIZE_ZIP}" \
        --keychain-profile "$PROFILE" \
        --wait
else
    # Use Apple ID credentials
    echo "Submitting with Apple ID credentials..."
    xcrun notarytool submit "${NOTARIZE_ZIP}" \
        --apple-id "$NOTARIZE_APPLE_ID" \
        --password "$NOTARIZE_PASSWORD" \
        --team-id "$NOTARIZE_TEAM_ID" \
        --wait
fi

echo ""
echo "Notarization submission completed."

# Staple the notarization ticket
echo ""
echo "Stapling notarization ticket to app..."
xcrun stapler staple "${APP_PATH}"

# Verify stapling
echo ""
echo "Verifying notarization..."
xcrun stapler validate "${APP_PATH}"

# Clean up
rm -f "${NOTARIZE_ZIP}"

echo ""
echo "✅ Notarization completed successfully!"
echo ""
echo "The app is now notarized and ready for distribution."
echo "You can now create distribution packages (ZIP/DMG)."