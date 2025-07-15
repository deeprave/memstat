# MemStat Testing Documentation

## Test Suite Overview

This document describes the comprehensive unit test suite for the MemStat macOS application. The tests focus on behavioral aspects and public APIs, ensuring at least 75% code coverage.

## Test Structure

### Test Files Created

1. **FormatUtilitiesTests.swift** - Tests for all utility formatting functions
2. **MemoryMonitorTests.swift** - Tests for memory statistics and process monitoring
3. **TableSectionTests.swift** - Tests for UI table section components
4. **MenuBarControllerTests.swift** - Tests for menu bar functionality
5. **StatsWindowControllerTests.swift** - Tests for stats window management
6. **TestHelpers.swift** - Common test utilities and mock data generators

### Test Coverage Areas

#### FormatUtilities Tests
- **formatBytes()** - Tests byte formatting (GB, MB, KB)
- **separateValueAndUnit()** - Tests string parsing and separation
- **createSortableHeaderText()** - Tests sorting indicator display
- **formatCount()** - Tests large number formatting (K, M suffixes)

Coverage: Comprehensive testing of all utility functions with edge cases

#### MemoryMonitor Tests
- **getMemoryStats()** - Tests system memory statistics retrieval
- **getTopProcesses()** - Tests process information and sorting
- **Memory pressure calculation** - Tests memory pressure detection
- **Process reliability** - Tests consistency of process data

Coverage: Tests core system monitoring functionality without testing internal implementation details

#### TableSection Tests
- **Section creation** - Tests proper initialization of all table section types
- **Data updates** - Tests data binding and display formatting
- **UI element creation** - Tests proper creation of labels and backgrounds
- **Mock delegate pattern** - Tests delegation without requiring full UI stack

Coverage: Tests all table section classes (Memory, Virtual, Swap, Process) through their public interfaces

#### MenuBarController Tests
- **Initialization** - Tests menu bar setup and status item creation
- **Menu structure** - Tests menu item creation and organization
- **Window management** - Tests stats window show/hide functionality
- **Memory management** - Tests proper cleanup and leak prevention

Coverage: Tests menu bar integration and window lifecycle management

#### StatsWindowController Tests
- **Window creation** - Tests window initialization and properties
- **Table delegation** - Tests proper setup of table section delegates
- **Data updates** - Tests memory statistics display updates
- **Appearance handling** - Tests light/dark mode support

Coverage: Tests window management and data presentation layers

### Test Infrastructure

#### Mock Objects
- **MockTableSectionDelegate** - Simulates table section delegation for testing
- **TestDataGenerator** - Creates realistic test data for memory stats and processes

#### Test Utilities
- **waitForCondition()** - Async testing utility with timeout
- **XCTAssertWithinTolerance()** - Floating point comparison with tolerance
- **Mock data generators** - Create consistent test data

## Running Tests

### Command Line
```bash
# Build tests
xcodebuild build -project MemStat.xcodeproj -target MemStatTests -configuration Debug

# Run tests with coverage (requires properly configured scheme)
xcodebuild test -project MemStat.xcodeproj -scheme MemStat -enableCodeCoverage YES
```

### Xcode
1. Open MemStat.xcodeproj in Xcode
2. Select the MemStatTests target
3. Use Product → Test (⌘+U) to run all tests
4. Use Product → Test with Code Coverage for coverage analysis

## Test Philosophy

### What We Test
- **Public APIs** - All public methods and properties
- **Behavioral contracts** - Expected behavior under various conditions
- **Integration points** - How components work together
- **Error conditions** - Handling of invalid inputs and edge cases

### What We Don't Test
- **Private implementation details** - Internal method implementations
- **System dependencies** - We test behavior, not system calls
- **UI rendering specifics** - We test data binding, not pixel-perfect rendering
- **Third-party frameworks** - We test our usage, not framework internals

## Code Coverage Goals

- **Target**: Minimum 75% line coverage
- **Focus areas**: All critical paths and business logic
- **Excluded**: Generated code, simple getters/setters, UI layout code

## Continuous Integration

The test suite is designed to:
- Run quickly (< 30 seconds for full suite)
- Be deterministic (no flaky tests)
- Provide clear failure messages
- Work in headless CI environments

## Test Data

All test data is generated programmatically to ensure:
- **Consistency** - Same data across test runs
- **Realism** - Data resembles actual system values
- **Isolation** - Tests don't depend on system state
- **Coverage** - Data covers edge cases and normal ranges

## Maintenance

### Adding New Tests
1. Create test methods following the naming pattern `testFeatureName()`
2. Use descriptive assertions with clear failure messages
3. Keep tests focused on single behaviors
4. Add mock data generators for complex types

### Updating Tests
1. Update tests when public APIs change
2. Maintain backward compatibility when possible
3. Document breaking changes in commit messages
4. Verify coverage remains above 75%

## Known Limitations

1. **UI Testing** - Limited UI automation testing (focus on unit tests)
2. **System Integration** - Tests use mocked system data where possible
3. **Performance Testing** - Basic performance validation, not comprehensive benchmarks
4. **Accessibility** - UI accessibility testing not included in unit tests

## Future Improvements

1. **Integration Tests** - Add tests that exercise full application workflows
2. **Performance Tests** - Add benchmarks for memory monitoring performance
3. **UI Tests** - Add automated UI testing using XCUITest framework
4. **Stress Tests** - Add tests for high memory usage scenarios