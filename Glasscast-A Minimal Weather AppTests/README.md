# Unit Tests for Glasscast Weather App

This directory contains comprehensive unit tests for the Glasscast Weather App.

## Test Structure

### Services Tests
- **AuthServiceTests.swift** - Tests for authentication service abstraction
- **WeatherAPIServiceTests.swift** - Tests for weather API service and data fetching
- **SupabaseServiceTests.swift** - Tests for Supabase favorites service

### ViewModel Tests
- **HomeViewModelTests.swift** - Tests for the home view model including loading states, refresh logic, and error handling

### Store Tests
- **FavoritesStoreTests.swift** - Tests for favorites management (add, remove, toggle, clear)
- **SelectedCityStoreTests.swift** - Tests for selected city state management

### Utility Tests
- **TemperatureUnitTests.swift** - Tests for temperature conversion (Celsius/Fahrenheit)
- **LoadingStateTests.swift** - Tests for loading state enum and equality
- **WeatherThemingTests.swift** - Tests for weather theme enumeration

### Model Tests
- **WeatherAPIModelsTests.swift** - Tests for API model decoding and encoding
- **FavoriteCityTests.swift** - Tests for FavoriteCity model
- **AppSessionTests.swift** - Tests for app session management

### Test Utilities
- **TestHelpers.swift** - Shared test utilities, builders, and helper functions

## Running Tests

### In Xcode
1. Open the project in Xcode
2. Press `Cmd+U` to run all tests
3. Or use `Cmd+6` to open the Test Navigator and run individual test suites

### From Command Line
```bash
xcodebuild test -scheme "Glasscast-A Minimal Weather App" -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage

The test suite covers:
- ✅ Service layer (API calls, error handling)
- ✅ ViewModel logic (state management, async operations)
- ✅ Store management (CRUD operations)
- ✅ Utility functions (temperature conversion, state management)
- ✅ Model encoding/decoding
- ✅ Error handling and edge cases

## Mock Objects

The tests use mock objects to isolate units under test:
- `MockWeatherService` - Mocks weather data fetching
- `MockSupabaseFavoriting` - Mocks Supabase favorites operations
- `MockURLSession` - Mocks network requests
- `TestDataBuilder` - Helper for creating test data

## Notes

- Tests marked with `@MainActor` run on the main thread (required for SwiftUI `@Published` properties)
- Some integration tests (like actual Supabase authentication) require real credentials and are better suited for integration test suites
- Mock services allow tests to run without network dependencies

## Adding New Tests

When adding new features:
1. Create corresponding test files following the naming convention: `[Component]Tests.swift`
2. Use the `TestDataBuilder` for creating test data
3. Follow the Given-When-Then pattern for clarity
4. Ensure tests are isolated and don't depend on external services
