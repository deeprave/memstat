#!/bin/bash
# Build script that ensures Version.swift is updated before building

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Default configuration
CONFIGURATION="Debug"
ACTION="build"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-c|--configuration Debug|Release] [-a|--action build|test|clean]"
            echo ""
            echo "Options:"
            echo "  -c, --configuration  Build configuration (Debug or Release, default: Debug)"
            echo "  -a, --action         Build action (build, test, or clean, default: build)"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Always generate version info before building (except for clean)
if [ "$ACTION" != "clean" ]; then
    echo "Generating Version.swift..."
    "$SCRIPT_DIR/generate_version.sh"
fi

# Execute the build
echo "Executing: xcodebuild -scheme MemStat -configuration $CONFIGURATION $ACTION"
xcodebuild -scheme MemStat -configuration "$CONFIGURATION" "$ACTION"