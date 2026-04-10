# KPFL Monorepo

KPFL is a monorepo for a Kyrgyz Premier League platform. Right now the repository contains:

- a Spring Boot backend
- a React/Vite admin panel
- a fully functional native iOS application

The project already covers public football data, admin CRUD flows, fantasy football backend logic, seed/demo data, and TheSportsDB synchronization.

## Repository Structure

- `backend` - Spring Boot API, auth, admin endpoints, fantasy logic, Flyway migrations
- `frontend-admin` - React 19 + Vite admin panel for clubs, players, matches, news, and fantasy operations
- `ios-user-application` - native iOS user app built with SwiftUI
- `render.yaml` - Render deployment blueprint for the backend

## Current Status

### Backend

Implemented:

- JWT authentication with `POST /auth/login`
- public API under `/api/**`
- admin API under `/admin/**`
- PostgreSQL + Flyway migrations
- fantasy module with teams, leagues, pricing, scoring, round recalculation
- TheSportsDB sync for KPFL matches
- demo fantasy data seeded into the database

Important notes:

- current backend deployment target is Render
- fantasy demo seed is intended for development/demo environments, not production editorial truth
- some tests require Docker/Testcontainers

### Frontend Admin

Implemented:

- login flow for admin JWT
- sections for `Clubs`, `Players`, `Matches`, `News`, `Fantasy`
- backend-backed CRUD forms for core entities
- fantasy tools for stat entry, price rebuild, and round recalculation
- Vite proxy for `/backend/*`
- Vercel-friendly SPA routing and backend rewrite support

Checked locally:

- `npm ci`
- `npm run build`

The production build succeeds.

### iOS User App

A high-performance, native iOS application providing a premium experience for Kyrgyz Premier League fans. Built with modern Apple technologies and a focus on real-time data and interactive features.

#### Key Features:
- **Comprehensive Fantasy Football:** 
    - Full squad management (15 players: 2GK, 5DF, 5MF, 3FW)
    - Real-time transfer market with price fluctuations
    - Private and Public leagues with live leaderboards
    - Gameweek-by-gameweek performance tracking and point history
    - Interactive pitch view for lineup management
- **Real-Time Match Center:**
    - Live match tracking, scores, and detailed event timelines
    - Interactive standings and league tables
    - Full match history and upcoming fixtures
- **Rich Content & Profiles:**
    - News feed with high-quality images and detailed articles
    - Detailed Player Profiles with season stats and career history
    - Club Profiles including squad lists, honors, and stadium info
- **Seamless Integration:**
    - Secure JWT-based authentication
    - Optimized API client with robust error handling and data mapping
    - Local data persistence and efficient caching

#### Technical Stack:
- **UI:** SwiftUI for a reactive and modern user interface
- **Architecture:** MVVM (Model-View-ViewModel) for clean separation of concerns
- **Concurrency:** Swift Concurrency (async/await) for smooth networking
- **Networking:** Generic API client over URLSession with DTO mapping
- **Tools:** Xcode, Asset Catalogs, Custom UI Components

## Contributors

- **Ayaz (@ayzsw)** — Lead iOS Developer (SwiftUI, Architecture, Fantasy Module)
- **@berrring** — Backend & Admin Panel Developer (Spring Boot, React)

## Quick Start

## 1. Requirements

- JDK 21
- Node.js 20+ or newer
- PostgreSQL
- Docker if you want backend tests that use Testcontainers

## 2. Run Backend

Windows:

```bat
cd backend
set "JAVA_HOME=C:\Users\user\.jdks\ms-21.0.8"
set "PATH=%JAVA_HOME%\bin;%PATH%"
mvnw.cmd spring-boot:run
```

Linux/macOS:

```bash
cd backend
./mvnw spring-boot:run
```

Default local URL:

- `http://localhost:8080`

Swagger/OpenAPI:

- `http://localhost:8080/swagger-ui/index.html`
- `http://localhost:8080/v3/api-docs`

## 3. Run Frontend Admin

```bash
cd frontend-admin
npm ci
npm run dev
```

Default local admin URL:

- `http://localhost:5173/admin/login`

By default the admin app calls the backend through:

- `/backend/*`

In local dev and preview mode this is proxied to:

- `https://kpfl.onrender.com`

If you want a different backend, set:

```env
VITE_API_BASE_URL=http://localhost:8080
```

or keep the built-in proxy:

```env
VITE_API_BASE_URL=/backend
```

## Seed Accounts

### Admin

- email: `admin@kpfl.local`
- password: `admin`

Use this account for:

- Swagger testing
- admin API
- `frontend-admin`

### Demo Fantasy Users

These were seeded to make fantasy testing non-empty:

- `askar.demo@kpfl.local` / `demo123`
- `aidana.demo@kpfl.local` / `demo123`
- `timur.demo@kpfl.local` / `demo123`

These users are useful for:

- `POST /auth/login`
- `/me/fantasy/team`
- `/me/fantasy/team/squad`
- `/me/fantasy/team/history`
- `/api/fantasy/leaderboard`

## Backend Configuration

Main environment variables:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `PORT`
- `JWT_SECRET`
- `JWT_ACCESS_EXPIRATION_MS`
- `THESPORTSDB_ENABLED`
- `THESPORTSDB_BASE_URL`
- `THESPORTSDB_LEAGUE_ID`
- `THESPORTSDB_SYNC_CRON`
- `THESPORTSDB_TIMEZONE`

Useful defaults currently in the project:

- TheSportsDB base URL: `https://www.thesportsdb.com/api/v1/json/123`
- league id: `4969`
- scheduled sync cron: `0 0 */2 * * *`
- scheduled sync timezone: `UTC`

## Deployment

## Backend on Render

Current monorepo setup:

- `Root Directory` = `backend`
- `Dockerfile Path` = `./Dockerfile`
- health check = `/actuator/health`

The repository also contains:

- `render.yaml`

## Frontend Admin on Vercel

Recommended:

- framework preset: `Vite`
- build command: `npm run build`
- output directory: `dist`

The admin app is already configured for SPA routing and same-origin backend proxying. See:

- `frontend-admin/vercel.json`
- `frontend-admin/DEPLOY_VERCEL.md`

## Data and Integrations

## TheSportsDB

The backend imports KPFL matches from TheSportsDB.

Current behavior:

- season import uses `eventsseason.php`
- live fallback endpoints still include next/past league events
- imported matches are upserted by external provider id
- club names are normalized with aliases for provider mismatches

Manual check endpoints:

- `POST /admin/import/thesportsdb`
- `GET /api/matches?seasonYear=2026`
- `GET /api/matches?seasonYear=2026&dateFrom=2026-04-01&dateTo=2026-04-30`

## Fantasy Demo Data

The latest demo migration makes the fantasy module usable immediately on a fresh database:

- demo users exist
- demo fantasy teams exist
- a demo fantasy league exists
- fantasy prices are preseeded
- a completed past round has fake fantasy scoring data
- a future round exists so the module is not permanently locked

This is useful for:

- admin fantasy screens
- leaderboard checks
- round history checks
- manual QA without first creating every team by hand

## Useful API Areas

Public:

- `/api/clubs`
- `/api/players`
- `/api/matches`
- `/api/news`
- `/api/standings`
- `/api/history/**`
- `/api/fantasy/leaderboard`
- `/api/fantasy/leagues/{leagueId}/leaderboard`
- `/api/fantasy/rounds/current`

Authenticated user:

- `/me/fantasy/team`
- `/me/fantasy/team/squad`
- `/me/fantasy/team/lineup`
- `/me/fantasy/team/transfers`
- `/me/fantasy/team/history`
- `/me/fantasy/leagues`

Admin:

- `/admin/clubs`
- `/admin/players`
- `/admin/matches`
- `/admin/news`
- `/admin/import/thesportsdb`
- `/admin/fantasy/teams`
- `/admin/fantasy/leagues`
- `/admin/fantasy/player-stats`
- `/admin/fantasy/prices/rebuild`
- `/admin/fantasy/recalculate/round/{seasonId}/{roundNumber}`

## Known Gaps

- admin panel currently focuses on create/update workflows; destructive flows are still limited
- fantasy content is demo-seeded, not editor-managed end-to-end yet
- TheSportsDB data quality depends on upstream naming and scheduling consistency
- local Spring tests that use Testcontainers will fail if Docker is not available
- Swagger auth UX is still basic and can be improved later

## Suggested Next Steps

- enhance iOS app features and UI
- add CI for backend compile/tests and frontend-admin build
- add stronger admin docs for fantasy operations
- add delete/archive flows where business rules allow them
- split environment configs more clearly for local vs Render vs Vercel

## Module Docs

- backend details: `backend/README.md`
- admin frontend details: `frontend-admin/README.md`
- iOS draft: `ios-user-application/README.md`
