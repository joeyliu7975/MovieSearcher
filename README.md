# MovieSearcher

A clean architecture iOS app that allows users to search for movies and view their details using The Movie Database API.

## Features

- 🔍 Search movies with pagination
- 📱 View movie details
- ⭐ Mark movies as favorite
- 💾 Offline-first with CoreData caching
- 🔄 Automatic background sync

## Setup

### Prerequisites

- **macOS**: 14.0 or later
- **Xcode**: 16.0 or later
- **iOS Deployment Target**: 18.2
- **Swift**: 5.0

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/joeyliu7975/MovieSearcher.git
   cd MovieSearcher/MovieSearcher
   ```

2. **Get your API credentials from [The Movie Database](https://www.themoviedb.org/settings/api)**

3. **Open `MovieSearcher/MovieSearcher/Info.plist` and add the following keys:**
   - `TMDB_API_KEY` - Your TMDB API Key
   - `TMDB_READ_ACCESS_TOKEN` - Your TMDB Read Access Token
   - `TMDB_ACCOUNT_ID` - Your TMDB Account ID (optional, for favorite functionality)

### Building and Running

#### Using Xcode (Recommended)

1. Open `MovieSearcher.xcodeproj` in Xcode
2. Select a simulator or connected device from the scheme menu
3. Press `Cmd + R` to build and run the app

#### Using Command Line

**Build the project:**
```bash
xcodebuild -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**Run the app:**
```bash
xcodebuild -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 16' run
```

**Or use xcrun simctl to install and launch:**
```bash
# Build
xcodebuild -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 16' build

# Install and launch
xcrun simctl boot "iPhone 16"
xcrun simctl install booted /path/to/MovieSearcher.app
xcrun simctl launch booted joeyliu.MovieSearcher
```

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns and **SOLID** principles.

### Architecture Overview

```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   (ViewControllers, ViewModels)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Repository Layer                  │
│   (Business Logic & Validation)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Decorator Layer                   │
│   (Caching Decorators)              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Composite Layer                   │
│   (Local + Remote Strategy)         │
└──────────────┬──────────────────────┘
        ┌──────┴──────┐
        │             │
┌───────▼──────┐ ┌───▼──────────┐
│ Local Layer  │ │ Remote Layer │
│ (CoreData)   │ │ (API)        │
└──────────────┘ └──────────────┘
```

## API

This app uses [The Movie Database (TMDB) API](https://developers.themoviedb.org/3/getting-started/introduction).

**Used Endpoints:**
- `GET /search/movie` - Search for movies
- `GET /movie/{movie_id}` - Get movie details by ID
- `GET /movie/{movie_id}/account_states` - Get account states
- `POST /account/{account_id}/favorite` - Mark movie as favorite

**Rate Limits:** 40 requests per 10 seconds per API key

## Testing

This project includes comprehensive **Unit Tests** and **UI Tests** to ensure code quality and reliability.

### Unit Tests

Unit tests cover the core business logic and data layer components using Swift Testing framework.

#### Repository Tests (`MovieRepositoryTests.swift`)
- ✅ Search movies (success, empty query, invalid page, data unavailable)
- ✅ Get movie details (success, invalid movie ID, data unavailable)
- ✅ Get account states (success, invalid movie ID, data unavailable)
- ✅ Mark as favorite (success, invalid movie ID, empty account ID)

#### ViewModel Tests

**SearchViewModel Tests** (`SearchViewModelTests.swift`)
- ✅ Search movies (success, empty query, error handling)
- ✅ Load next page (success, when loading, no more pages)
- ✅ Has more pages (true/false scenarios)
- ✅ Reset functionality (clears state)

**MovieDetailViewModel Tests** (`MovieDetailViewModelTests.swift`)
- ✅ Load movie detail (success, error)
- ✅ Load account states (success, no account ID, error)
- ✅ Toggle favorite (success, error, no account ID, no favorite state)

#### Data Loader Tests

**CompositeMovieDataLoader Tests** (`CompositeMovieDataLoaderTests.swift`)
- ✅ Search movies (local first, remote fallback, both fail)
- ✅ Get movie detail (local first, remote fallback, both fail)

**CompositeAccountStatesLoader Tests** (`CompositeAccountStatesLoaderTests.swift`)
- ✅ Get account states (local first, remote fallback, both fail, no account ID)
- ✅ Mark as favorite (success, remote fails with rollback)

**CachingMovieDataDecorator Tests** (`CachingMovieDataDecoratorTests.swift`)
- ✅ Search movies (caches result, store error does not fail)
- ✅ Get movie detail (caches result, store error does not fail)

**Running Unit Tests:**
```bash
# In Xcode: Cmd + U
# Or via command line:
xcodebuild test -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MovieSearcherTests
```

### UI Tests

UI tests verify the complete user experience and interactions using XCTest framework.

#### Search Tests (`SearchViewControllerUITests.swift`)
- ✅ Initial empty state
- ✅ Successful search
- ✅ Search bar cancel button functionality
- ✅ Empty query handling
- ✅ Loading indicators
- ✅ Table view display
- ✅ Scroll to load more (pagination)

#### Navigation Tests (`NavigationUITests.swift`)
- ✅ Navigate to movie detail
- ✅ Navigate back from detail

#### Detail Tests (`MovieDetailViewControllerUITests.swift`)
- ✅ Movie detail display
- ✅ Loading state
- ✅ Favorite button visibility
- ✅ Content scrolling

#### Favorite Tests (`FavoriteUITests.swift`)
- ✅ Toggle favorite (add to favorites, remove from favorites)
- ✅ Favorite button visibility

#### Error Handling Tests (`ErrorHandlingUITests.swift`)
- ✅ Search error display
- ✅ Detail load error
- ✅ Network error handling

#### End-to-End Tests (`EndToEndUITests.swift`)
- ✅ Complete search-to-detail flow
- ✅ Search pagination flow
- ✅ Search cancel and resume
- ✅ Multiple detail navigation

#### Launch Tests (`MovieSearcherUITestsLaunchTests.swift`)
- ✅ App launch performance and screenshots

**Running UI Tests:**
```bash
# In Xcode: Select MovieSearcherUITests scheme and Cmd + U
# Or via command line:
xcodebuild test -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MovieSearcherUITests
```

**Running All Tests:**
```bash
xcodebuild test -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Test Coverage

The test suite covers:
- **Business Logic**: Repository validation and error handling
- **ViewModels**: State management and user interactions
- **Data Layer**: Local/remote data loading strategies, caching, and error recovery
- **UI Components**: User interactions, navigation, and error states
- **End-to-End Flows**: Complete user journeys from search to detail

### Test Helpers

- **TestHelpers.swift**: Utilities for unit tests (mock data, async helpers)
- **UITestHelpers.swift**: Utilities for UI tests (app launch, keyboard handling, element waiting)
- **Mocks/**: Mock implementations for testing (MockMovieDataLoader, MockAccountStatesLoader, etc.)
