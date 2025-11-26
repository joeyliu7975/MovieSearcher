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
