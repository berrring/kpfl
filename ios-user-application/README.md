# KPFL iOS App

KPFL is an iOS app for Kyrgyz Premier League content:
- matches and standings
- clubs and players
- news and stats
- fantasy league (team, squad, gameweek, leagues)

## Tech Stack

- Swift
- SwiftUI
- Xcode project: `KPFL.xcodeproj`
- Backend API: `https://kpfl.onrender.com`

## Features

- Authentication: register/login
- Home dashboard with latest league data
- Matches with filters
- Standings table
- Club profile / player profile
- News feed + detail
- Fantasy:
  - create fantasy team
  - build and update squad
  - gameweek view
  - league leaderboard
  - join league / create league
- App settings:
  - theme mode: `System / Light / Dark`

## Project Structure

- `KPFL/` - app entry files (`KPFLApp`, `ContentView`, `AppSettings`)
- `Sreens/` - all screens and feature UI
- `Sreens/Fantasy/` - fantasy module (`Models`, `ViewModels`, `Views`, `Services`)
- `Network/` - API layer and DTOs
- `Views/` - reusable UI components
- `KPFL.xcodeproj/` - Xcode project config

## Run Locally

1. Open `KPFL.xcodeproj` in Xcode.
2. Select scheme `KPFL`.
3. Set your signing team in:
   `TARGETS -> KPFL -> Signing & Capabilities`.
4. Build and run on simulator or device.

## API Notes

- Public endpoints are used for league content (`/api/*`).
- Authorized fantasy endpoints use Bearer token (`/me/fantasy/*`).
- Token is stored locally after login/register.

## Known Notes for Demo

- If backend is temporarily unavailable, fantasy player selection uses local fallback data.
- Some backend operations require authenticated user state.

## Version

- Current app version in UI: `1.0.0`

