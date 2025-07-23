# ChangeLog

All notable changes to MemStat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **Process Table Headers**: Fixed headers not displaying sort indicators on initial load
  - Headers now correctly show sort arrows (▲/▼) and active column highlighting immediately
  - Previously required clicking a header to trigger proper display formatting
  - Added missing initialization call to updateAllProcessHeaders() after header creation
- **Appearance Menu State**: Fixed appearance menu not updating checkmarks after mode change
  - Menu checkmarks now correctly follow the selected appearance mode (System/Light/Dark)
  - Fixed incorrect menu registration - now registers the app menu containing appearance items
  - Menu update system now properly tracks and updates the correct menu instance

## [1.3.0] - 2025-07-24

### Fixed
- **Critical Memory Leak**: Fixed UpdateCoordinator timer not being invalidated in deinit
  - Added deinit method to UpdateCoordinator to properly invalidate timer
  - Prevents crashes when UpdateCoordinator is deallocated without explicit stopUpdating() call
  - Ensures proper cleanup of system resources and prevents memory leaks
- **Memory Info Architecture**: Refactored memory information structs for better organization and reduced boilerplate
  - Moved BasicMemoryInfo, DetailedMemoryInfo, AppMemoryInfo, and SwapInfo as nested types within MemoryStats
  - Added static factory methods (mock()) to each nested type for simplified test data generation
  - Removed deprecated type aliases after migrating all code to use nested types
  - Reduced test boilerplate by utilizing factory methods instead of manual struct instantiation
- **UpdateCoordinator Threading**: Fixed timer thread safety for UI interactions
  - Added explicit RunLoop.main scheduling with .common mode for timer callbacks
  - Ensures UI updates from timer callbacks are always performed on the main thread
- **AppearanceManager Menu Updates**: Fixed bug where `setAppearance()` did not update appearance menus after changing mode
  - Added menu registration system to AppearanceManager for automatic menu updates when appearance changes
  - Registered appearance menus in both AppDelegate (window mode) and MenuBarController (menu bar mode)
  - All appearance menus now automatically reflect the current mode selection with proper checkmarks

### Added
- **Comprehensive Test Coverage**: Added extensive test suites for critical system integration points
  - LoginItemsManagerTests: 17 tests covering cross-platform compatibility, error handling, and concurrent access
  - MainTests: 22 tests for multiple instance detection logic and NSWorkspace integration
  - AppDelegateCommandLineTests: 22 tests for command line parsing and application restart mechanisms
  - UpdateCoordinatorTests: Enhanced testing of timer behavior, memory management, and error handling
  - Overall test coverage improved from 75.21% to 75.87% (2261/2980 lines covered)

### Changed
- **Code Organization**: Improved namespace organization by moving memory info structs as nested types
- **Testing Strategy**: Implemented comprehensive testing strategy for all low-coverage system integration areas

### Security
- **UpdateCoordinator Validation**: Added minimum interval validation to prevent timer flooding
  - Timer intervals below 0.1 seconds are now clamped to prevent overwhelming the run loop
  - Protects against accidental or malicious attempts to consume excessive CPU resources
- **Memory Management**: Fixed potential memory leaks in AppearanceManager
  - Implemented weak reference pattern for menu tracking to prevent retain cycles
  - Automatic cleanup of deallocated menus to maintain proper memory hygiene

### Improved
- **Resource Management**: Enhanced component lifecycle management for better reliability
  - Added cleanup safeguards in StatsWindowController deinit to ensure timer shutdown
  - Prevents potential resource leaks if normal shutdown sequence is interrupted
- **Menu System Architecture**: Improved AppearanceManager menu update mechanism
  - Fixed WeakMenuReference capture to prevent premature wrapper deallocation
  - Enhanced closure capture semantics for more robust menu state synchronization
  - Direct menu updates provide explicit control over appearance state propagation
- **Layout System Consolidation**: Unified layout constants into centralized management
  - Moved ProcessTableColumn and layout logic to TableLayoutManager for consistency
  - Eliminated duplicate LocalProcessTableLayout reducing maintenance overhead
  - Centralized process table configuration improves code organization and reduces duplication
- **Timer Management**: Fixed UpdateCoordinator timer scheduling to prevent duplicate registration
  - Changed from scheduledTimer to Timer(timeInterval:) with explicit RunLoop registration
  - Eliminates potential scheduling conflicts and ensures proper timer lifecycle management
- **UpdateCoordinator Race Conditions**: Added guard against repeated startUpdating calls
  - Prevents overlapping timer schedules and race conditions from multiple start requests
  - Timer creation now skipped if timer is already active, ensuring single timer per coordinator
- **AppearanceManager Memory Growth**: Implemented explicit menu unregistration system
  - Added unregisterMenuForUpdates() and unregisterAllMenusForTarget() methods
  - Enhanced WeakTargetReference tracking to prevent unbounded closure accumulation
  - AppDelegate and MenuBarController now automatically unregister menus in deinit
  - Prevents memory leaks from accumulating appearance menu registrations
- **Type Safety**: Replaced Objective-C perform() calls with Swift protocol interface in AppearanceManager
  - Created AppearanceMenuUpdateDelegate protocol for type-safe menu update callbacks
  - Eliminated runtime selector validation and improved compile-time error detection
  - AppearanceMenuHandler now uses Swift delegate pattern instead of target-action with perform()
  - Updated AppDelegate and MenuBarController to conform to new delegate protocol
  - Enhanced memory management with proper weak delegate references

## [1.2.3] - 2025-07-23

### Fixed
- **AppearanceManager Menu Identification**: Replaced fragile string-based menu item identification with robust tag-based system using MenuTag enum
- **Singleton Issues**: Fixed AppearanceMenuHandler singleton pattern that could cause issues with multiple menu instances by creating per-menu handlers
- **Memory Management**: Added AppearanceMenuData wrapper for proper memory management in appearance menu handling
- **Test Result Bundle Warnings**: Configured test scheme to use explicit result bundle path, eliminating `mkstemp: No such file or directory` warnings during test execution

### Enhanced
- **UpdateCoordinator**: Added immediate execution option to `startUpdating(immediate: Bool = false)` method to support immediate stats display on window opening
- **Code Quality**: Improved menu handling architecture to be more maintainable and less prone to localization issues

### Technical
- **Menu System**: Introduced MenuTag enum with integer-based menu identification instead of string comparison
- **Test Infrastructure**: Added `resultBundlePath = "/tmp/memstat-test-results.xcresult"` to test scheme configuration
- **Architecture**: Moved from singleton to per-instance pattern for appearance menu handlers

## [1.2.2] - 2025-07-23

### Fixed
- **Code Maintainability**: Comprehensive code refactoring for improved maintainability and SOLID compliance
  - Removed unnecessary comments while preserving MARK navigation, API documentation, and complex logic explanations
  - Simplified obtuse syntax and improved code readability
  - Extracted duplicate appearance management code into centralized AppearanceManager
  - Created UpdateCoordinator to handle timer management and reduce coupling
  - Refactored MemoryStats constructor from 19 parameters to structured approach with BasicMemoryInfo, DetailedMemoryInfo, AppMemoryInfo, and SwapInfo
- **Build System**: All new refactored files properly added to Xcode project for successful builds
- **Test Coverage**: All 104 tests pass after refactoring, confirming functionality preservation

### Added
- **AppearanceManager**: Centralized appearance management following SOLID principles
- **UpdateCoordinator**: Extracted timer management from StatsWindowController for better separation of concerns
- **Structured Data Types**: Organized MemoryStats with grouped information structures for better maintainability

### Changed
- **Code Organization**: Improved SOLID principles compliance throughout codebase
- **Constructor Patterns**: Simplified complex constructors with structured data approach
- **Architecture**: Better separation of concerns with dedicated managers for specific functionality

## [1.2.1] - 2025-07-23

### Fixed
- **CI/CD Pipeline**: Fixed GitHub Actions workflow issues
  - Removed dependency on `just` build tool in CI pipelines due to compatibility challenges
  - Updated workflows to use direct `xcodebuild` commands for better reliability
  - Fixed release workflow permissions and asset path issues
  - Removed manual workflow dispatch trigger that was incompatible with release automation

### Technical
- **GitHub Actions**: Streamlined build and release workflows for better maintainability
- **Build System**: Direct xcodebuild integration for more predictable CI/CD execution

## [1.2.0] - 2025-07-23

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

## [1.1.1] - 2025-07-21

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
