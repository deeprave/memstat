#!/bin/bash

# Script to create a styled DMG with custom window settings
# This creates a more professional-looking DMG with icon positioning

set -e  # Exit on error

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Configuration
APP_NAME="MemStat"
BUILD_DIR="${PROJECT_DIR}/build/Build/Products/Release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DIST_DIR="${PROJECT_DIR}/dist"
TEMP_DIR="${PROJECT_DIR}/build/dmg_temp"

# Get version from git
VERSION=$(cd "$PROJECT_DIR" && git describe --tags --always --dirty 2>/dev/null || echo "unknown")
# Remove 'v' prefix if present
VERSION_CLEAN=${VERSION#v}

# Output filename
DMG_NAME="${APP_NAME}-${VERSION_CLEAN}.dmg"
DMG_PATH="${DIST_DIR}/${DMG_NAME}"
VOLUME_NAME="${APP_NAME} ${VERSION_CLEAN}"

echo "=== ${APP_NAME} Styled DMG Packager ==="
echo "Version: ${VERSION_CLEAN}"
echo ""

# Check if release build exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: Release build not found at ${APP_PATH}"
    echo ""
    echo "Please build the app in Release configuration first:"
    echo "  xcodebuild -scheme ${APP_NAME} -configuration Release build"
    echo "Or use Xcode: Product > Build For > Archiving"
    exit 1
fi

# Check code signing status - REQUIRED for distribution
echo "Checking code signing status..."
if codesign --verify "${APP_PATH}" >/dev/null 2>&1; then
    SIGNATURE_INFO=$(codesign --display --verbose=2 "${APP_PATH}" 2>&1 | grep "Authority=" | head -1)
    echo "✅ App is code signed: ${SIGNATURE_INFO#Authority=}"
else
    echo ""
    echo "❌ ERROR: App is not code signed or signature is invalid."
    echo ""
    echo "For distribution, the app MUST be code signed."
    echo "Please run the following command first:"
    echo "  ./Scripts/codesign_app.sh"
    echo ""
    echo "Aborting styled DMG creation."
    exit 1
fi
echo ""

# Check if create-dmg is installed
if ! command -v create-dmg &> /dev/null; then
    echo "Warning: create-dmg not found. Installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew not found. Please install Homebrew first."
        echo "Visit: https://brew.sh"
        echo ""
        echo "Alternatively, use package_dmg.sh for a basic DMG."
        exit 1
    fi
    brew install create-dmg
fi

# Create directories
mkdir -p "${DIST_DIR}"

# Clean up any existing files
if [ -f "${DMG_PATH}" ]; then
    echo "Removing existing DMG..."
    rm "${DMG_PATH}"
fi

echo "Creating styled DMG with create-dmg..."

# Create DMG with nice styling
create-dmg \
    --volname "${VOLUME_NAME}" \
    --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "${APP_NAME}.app" 150 190 \
    --hide-extension "${APP_NAME}.app" \
    --app-drop-link 450 190 \
    --no-internet-enable \
    --hdiutil-quiet \
    "${DMG_PATH}" \
    "${APP_PATH}"

# Optional: Sign the DMG if you have a Developer ID
# echo "Signing DMG..."
# codesign --force --sign "Developer ID Application: Your Name" "${DMG_PATH}"

# Get file size
SIZE=$(ls -lh "${DMG_PATH}" | awk '{print $5}')

echo ""
echo "✅ Success!"
echo "Created: ${DMG_PATH}"
echo "Size: ${SIZE}"
echo ""
echo "This styled DMG file is ready for distribution."
echo "It includes:"
echo "- Custom window size and position"
echo "- App icon and Applications folder shortcut"
echo "- Professional appearance"
echo ""
echo "Note: For distribution outside the App Store, you should:"
echo "1. Sign the app with a Developer ID certificate"
echo "2. Notarize the app with Apple"
echo "3. Sign the DMG"
echo "4. Notarize the DMG"
