# GitHub Actions Workflows

This directory contains GitHub Actions workflows for building, testing, and releasing the MemStat application.

## Workflows

### build-and-test.yml
Runs on every push to main/develop branches and on pull requests.
- Builds the app in both Debug and Release configurations
- Runs all tests
- Performs code quality checks with SwiftLint
- Uploads build artifacts

### release.yml
Triggered by version tags (v*) or manual workflow dispatch.
- Builds a release version
- Code signs the application
- Notarizes the app with Apple
- Creates DMG and ZIP packages
- Creates a GitHub release with artifacts

## Required Secrets

Configure these in your repository settings under Settings → Secrets and variables → Actions:

### For Code Signing (release.yml)
- `CERTIFICATES_P12`: Base64-encoded P12 certificate file containing your Developer ID Application certificate
- `CERTIFICATES_P12_PASSWORD`: Password for the P12 certificate file
- `CODESIGN_IDENTITY`: Your code signing identity (e.g., "Developer ID Application: Your Name (TEAMID)")

### For Notarization (release.yml)
- `NOTARIZATION_USERNAME`: Your Apple ID email
- `NOTARIZATION_PASSWORD`: App-specific password for notarization
- `NOTARIZATION_TEAM_ID`: Your Apple Developer Team ID

## Environment Variables

No additional environment variables are required. The workflows use:
- `DEVELOPER_DIR`: Set to `/Applications/Xcode.app/Contents/Developer` (standard Xcode location)

## Repository Variables

No repository variables are required for these workflows.

## Setup Instructions

1. Generate a Developer ID Application certificate in your Apple Developer account
2. Export the certificate as a P12 file
3. Convert to base64: `base64 -i certificate.p12 | pbcopy`
4. Create an app-specific password at https://appleid.apple.com
5. Add all secrets to your GitHub repository settings

## Notes

- The build-and-test workflow uses the latest stable Xcode version
- SwiftLint checks are run but won't fail the build (continue-on-error: true)
- Test results and build artifacts are retained for different periods:
  - Test results: 30 days
  - Debug builds: 7 days
  - Release builds: 30 days
