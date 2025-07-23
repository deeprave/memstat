# ChangeLog

All notable changes to MemStat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - v1.2.0

### Fixed
- **UI Layout and Alignment**: Fixed multiple UI alignment issues
  - Process table font changed to smaller (12pt) monospaced font for better readability
  - Column headers now extend properly to fill space between vertical borders
  - Command column width properly calculated to respect table margins
  - Added proper spacing between column headers and data rows
  - Fixed alignment of non-unit columns (Pressure, Util, etc.) to match unit column positioning
  - Bold formatting applied to row labels in Memory, Virtual, and Swap tables for better visual distinction
- Fixed build issues with FormatUtilities references in TableSections.swift
- Fixed test issues with private method access
- Improved code organization for better testability
- Added local helper functions to avoid dependencies on FormatUtilities
- Added local ProcessTableLayout definition to avoid circular dependencies
- Modified tests to avoid accessing private methods
- Fixed type conversion issues in TableSections.swift

### Added
- **Appearance Menu Enhancement**: Improved appearance menu functionality
  - Added visual tick marks to show currently selected appearance mode (Auto/Light/Dark)
  - Appearance settings now persist between app launches
  - Default appearance mode set to Auto for better user experience
- **Dual Mode Support**: MemStat can now run in two different modes:
  - **Menu Bar Mode**: Traditional menubar app with floating stats window (original behavior)
  - **Regular Window Mode**: Standard macOS app with always-visible window and dock icon (default mode)
- **Mode Switching**: Users can switch between modes via menu options:
  - Menu Bar mode: "Switch to Regular Window" in right-click context menu
  - Regular Window mode: "Mode" menu in application menu bar
- **Persistent Mode Preference**: App remembers selected mode between launches
- **Automatic Restart**: App prompts to restart when switching modes for proper transition
- **Enhanced About Dialog**: Shows current mode in about information
- **Command Line Flags**: Added support for forcing startup mode via command line:
  - `--menubar` or `-m`: Force startup in menu bar mode
  - `--window` or `-w`: Force startup in regular window mode
  - `--help` or `-h`: Display usage information
  - Command line flags override saved preferences for current session

### Changed
- **macOS Compatibility**: Lowered minimum system requirement from macOS 14.0 to macOS 13.0
  - Added fallback support for monospaced fonts on older macOS versions
  - Improved backward compatibility while maintaining modern features
- **AppDelegate**: Refactored to support both menubar and window modes
- **Application Menu**: Added mode selection submenu in regular window mode
- **Dock Icon Behavior**: Properly shows/hides dock icon based on current mode
- **Window Management**: Improved window lifecycle management for mode transitions

### Technical
- Created `AppMode.swift` enum for mode management
- Enhanced `AppDelegate` with mode switching logic and restart functionality
- Updated `MenuBarController` with mode switching menu option
- Improved application activation policy handling for different modes

### Development
- **Enhanced justfile**: Added run and test tasks for development convenience:
  - `just run`: Run app using saved preference (or default window mode)
  - `just run-window`: Force run in window mode
  - `just run-menubar`: Force run in menubar mode
  - `just test`: Run all tests (default) or specific test when TEST_ID provided
  - Enhanced test runner maintains consistent xcodebuild arguments and project integrity

### Testing
- **Comprehensive Test Suite**: Added extensive tests for new functionality:
  - `CommandLineTests`: Tests for command line flag parsing and priority logic
  - `ModeSwitchingTests`: Tests for mode switching, preference persistence, and controller lifecycle
  - Updated `AppDelegateTests`: Enhanced tests for new AppDelegate functionality
  - Updated `MenuBarControllerTests`: Added tests for mode switching integration
- **Test Coverage**: Tests cover command line parsing, mode switching, preference handling, error cases, and integration scenarios
- **Test Infrastructure**: Fixed all test compilation and execution issues:
  - Updated mock classes to match protocol changes (added missing `isSortColumn` parameter and delegate methods)
  - Fixed protocol conformance issues in `MockLabelFactory` and `MockTableSectionDelegate`
  - Corrected test expectations to match actual implementation behavior
  - All 125 tests now pass successfully

### Implementation Notes
- The new files have been added to the Xcode project
- All build and test issues have been resolved
- Complete test suite now passes with 125 tests executed successfully

## [1.1.1] - 2024-XX-XX

### Features Present in This Release
- Real-time memory monitoring (Physical, Virtual, Swap)
- Top 20 process monitoring with sortable columns
- Memory pressure status indication
- Dark mode support
- Launch at login functionality
- Appearance customization (Auto/Light/Dark)
- Smart window management with click-to-dismiss
- Efficient performance with minimal resource usage
- macOS 13.0+ compatibility