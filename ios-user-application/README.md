# iOS User Application

This folder does not contain a real iOS app yet.

It exists to reserve the module and define the intended Swift direction for the user-facing mobile client.

## Intended Stack

- Swift 5.10+
- SwiftUI
- async/await networking
- `URLSession` for API access
- lightweight token storage via Keychain
- optional local caching for read-heavy screens

## Intended Product Scope

The iOS app should be a user-facing client, not an admin tool.

Expected first-version features:

- authentication
- clubs list and club details
- players list and player details
- matches list and match details
- standings
- news feed
- fantasy team management
- fantasy lineup and transfer flows
- fantasy leaderboard

## Suggested App Structure

One reasonable starting point:

- `App/`
  - app entry point
  - root navigation
  - dependency container
- `Features/Auth/`
- `Features/Clubs/`
- `Features/Players/`
- `Features/Matches/`
- `Features/News/`
- `Features/Fantasy/`
- `Networking/`
  - API client
  - request builders
  - auth interceptor
- `Models/`
- `Storage/`
  - token storage
  - optional simple cache
- `DesignSystem/`

## Backend Endpoints To Use

Public API:

- `GET /api/clubs`
- `GET /api/clubs/{id}`
- `GET /api/players`
- `GET /api/players/{id}`
- `GET /api/matches`
- `GET /api/matches/{id}`
- `GET /api/news`
- `GET /api/news/{id}`
- `GET /api/standings`
- `GET /api/history/**`
- `GET /api/fantasy/leaderboard`
- `GET /api/fantasy/rounds/current`

Authenticated user API:

- `POST /auth/login`
- `GET /me/fantasy/team`
- `GET /me/fantasy/team/squad`
- `PUT /me/fantasy/team/lineup`
- `POST /me/fantasy/team/transfers`
- `GET /me/fantasy/team/history`
- `GET /me/fantasy/leagues`
- `POST /me/fantasy/leagues`
- `POST /me/fantasy/leagues/join`

## Suggested First Milestone

Build a minimal SwiftUI shell with:

- login screen
- tab navigation
- clubs screen
- matches screen
- news screen
- fantasy screen

That gives enough surface area to validate:

- auth flow
- API models
- token persistence
- navigation style
- loading and error states

## Practical Notes

- backend JWT is already available through `POST /auth/login`
- demo fantasy users are already seeded in the backend database
- the app should treat admin endpoints as out of scope
- if the app targets App Store distribution later, API base URLs should be environment-specific

## What Is Missing Today

- no Xcode project
- no Swift package/module layout
- no networking layer yet
- no design system yet
- no push notification or offline strategy yet

This file is intentionally a rough implementation guide so the Swift app can be started cleanly later.
