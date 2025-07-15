#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Change to project directory to ensure git commands work
cd "$PROJECT_DIR"

# Get version from git
# git describe --tags will give us:
# - v1.0.0 (if we're exactly on a tag)
# - v1.0.0-5-g3a4b5c6 (5 commits after tag v1.0.0, commit hash 3a4b5c6)
# - v1.0.0-5-g3a4b5c6-dirty (if working directory has uncommitted changes)
GIT_VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0")

# Get the commit count for build number
BUILD_NUMBER=$(git rev-list --count HEAD 2>/dev/null || echo "0")

# Get the short commit hash
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Generate the Swift file
cat > "$PROJECT_DIR/MemStat/Version.swift" << EOF
//
//  Version.swift
//  MemStat
//
//  Auto-generated file - DO NOT EDIT
//  Generated on $(date)
//

struct AppVersion {
    /// Full version string from git describe (e.g., "v1.0.0-5-g3a4b5c6-dirty")
    static let gitVersion = "$GIT_VERSION"
    
    /// Build number (total commit count)
    static let buildNumber = "$BUILD_NUMBER"
    
    /// Short commit hash
    static let commitHash = "$COMMIT_HASH"
    
    /// User-friendly version string (strips the 'v' prefix)
    static var displayVersion: String {
        gitVersion.hasPrefix("v") ? String(gitVersion.dropFirst()) : gitVersion
    }
}
EOF

echo "Generated Version.swift with version: $GIT_VERSION"