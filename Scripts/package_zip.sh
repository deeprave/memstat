#!/bin/bash

# Script to create a distributable ZIP file from a release build

set -e  # Exit on error

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Configuration
APP_NAME="MemStat"
BUILD_DIR="${PROJECT_DIR}/build/Build/Products/Release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DIST_DIR="${PROJECT_DIR}/dist"

# Get version from git
VERSION=$(cd "$PROJECT_DIR" && git describe --tags --always --dirty 2>/dev/null || echo "unknown")
# Remove 'v' prefix if present
VERSION_CLEAN=${VERSION#v}

# Output filename
ZIP_NAME="${APP_NAME}-${VERSION_CLEAN}.zip"
ZIP_PATH="${DIST_DIR}/${ZIP_NAME}"

echo "=== ${APP_NAME} ZIP Packager ==="
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
    echo "Aborting ZIP creation."
    exit 1
fi
echo ""

# Create dist directory if it doesn't exist
mkdir -p "${DIST_DIR}"

# Remove old ZIP if it exists
if [ -f "${ZIP_PATH}" ]; then
    echo "Removing existing ZIP..."
    rm "${ZIP_PATH}"
fi

# Create the ZIP file
echo "Creating ZIP archive..."
cd "${BUILD_DIR}"

# Use ditto to preserve macOS metadata and create a proper ZIP
ditto -c -k --keepParent "${APP_NAME}.app" "${ZIP_PATH}"

# Verify the ZIP
echo ""
echo "Verifying ZIP archive..."
unzip -t "${ZIP_PATH}" > /dev/null

# Get file size
SIZE=$(ls -lh "${ZIP_PATH}" | awk '{print $5}')

echo ""
echo "✅ Success!"
echo "Created: ${ZIP_PATH}"
echo "Size: ${SIZE}"
echo ""
echo "This ZIP file is ready for distribution."
echo "Users can extract it and drag ${APP_NAME}.app to their Applications folder."