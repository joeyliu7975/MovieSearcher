# MovieSearcher

A simple iOS app that allows users to search for movies and view their details using The Movie Database API.

## Setup

1. Copy `Info.plist.example` to `Info.plist`:
   ```bash
   cp MovieSearcher/MovieSearcher/Info.plist.example MovieSearcher/MovieSearcher/Info.plist
   ```

2. Get your API credentials from [The Movie Database](https://www.themoviedb.org/settings/api)

3. Open `MovieSearcher/MovieSearcher/Info.plist` and replace:
   - `YOUR_API_KEY_HERE` with your TMDB API Key
   - `YOUR_READ_ACCESS_TOKEN_HERE` with your TMDB Read Access Token

4. Build and run the project in Xcode

## API

This app uses [The Movie Database (TMDB) API](https://developers.themoviedb.org/3/getting-started/introduction).

**Used Endpoints:**
- `GET /search/movie` - Search for movies
- `GET /movie/{movie_id}` - Get movie details by ID

**Rate Limits:**
- 40 requests per 10 seconds per API key
- See [TMDB API Documentation](https://developers.themoviedb.org/3/getting-started/introduction) for details

For complete API documentation, visit: https://developers.themoviedb.org/3

## Security Note

The `Info.plist` file containing API keys is excluded from version control via `.gitignore`. Never commit your actual API keys to the repository.