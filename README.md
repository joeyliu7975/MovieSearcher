# MovieSearcher

A clean architecture iOS app that allows users to search for movies and view their details using The Movie Database API.

## Features

- 🔍 Search movies with pagination
- 📱 View movie details
- ⭐ Mark movies as favorite
- 💾 Offline-first with CoreData caching
- 🔄 Automatic background sync

## Setup

1. Copy `Info.plist.example` to `Info.plist`:
   ```bash
   cp MovieSearcher/MovieSearcher/Info.plist.example MovieSearcher/MovieSearcher/Info.plist
   ```

2. Get your API credentials from [The Movie Database](https://www.themoviedb.org/settings/api)

3. Open `MovieSearcher/MovieSearcher/Info.plist` and add the following keys:
   - `TMDB_API_KEY` - Your TMDB API Key
   - `TMDB_READ_ACCESS_TOKEN` - Your TMDB Read Access Token
   - `TMDB_ACCOUNT_ID` - Your TMDB Account ID (optional, for favorite functionality)

4. Build and run the project in Xcode

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

Unit tests cover the core business logic and data layer components:

- **Repository Tests** (`MovieRepositoryTests.swift`)
  - Search movies (happy & sad paths)
  - Get movie details (happy & sad paths)
  - Get account states (happy & sad paths)
  - Mark as favorite (happy & sad paths)

- **ViewModel Tests**
  - `SearchViewModelTests.swift` - Search functionality, pagination, error handling
  - `MovieDetailViewModelTests.swift` - Detail loading, favorite toggling, account states

- **Data Loader Tests**
  - `CompositeMovieDataLoaderTests.swift` - Composite pattern for local/remote loading
  - `CompositeAccountStatesLoaderTests.swift` - Account states loading with rollback
  - `CachingMovieDataDecoratorTests.swift` - Caching decorator functionality

**Running Unit Tests:**
```bash
# In Xcode: Cmd + U
# Or via command line:
xcodebuild test -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests

UI tests verify the complete user experience and interactions:

- **Search Tests** (`SearchViewControllerUITests.swift`)
  - Initial empty state
  - Successful search
  - Cancel button functionality
  - Loading indicators
  - Table view display
  - Scroll to load more

- **Navigation Tests** (`NavigationUITests.swift`)
  - Navigate to movie detail
  - Navigate back from detail

- **Detail Tests** (`MovieDetailViewControllerUITests.swift`)
  - Detail display
  - Loading state
  - Favorite button visibility
  - Content scrolling

- **Favorite Tests** (`FavoriteUITests.swift`)
  - Toggle favorite status
  - Button state updates

- **Error Handling Tests** (`ErrorHandlingUITests.swift`)
  - Search error display
  - Detail load error
  - Network error handling

- **End-to-End Tests** (`EndToEndUITests.swift`)
  - Complete search-to-detail flow
  - Search pagination flow
  - Search cancel and resume
  - Multiple detail navigation

**Running UI Tests:**
```bash
# In Xcode: Select MovieSearcherUITests scheme and Cmd + U
# Or via command line:
xcodebuild test -scheme MovieSearcher -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MovieSearcherUITests
```
