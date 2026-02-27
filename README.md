# KPFL Backend

Backend for the KPFL platform (iOS app + Admin client) built with Spring Boot.

## Tech Stack

- Java 21
- Spring Boot 4 (WebMVC, Data JPA, Security, Validation)
- JWT (access token)
- PostgreSQL 16
- Flyway migrations
- Springdoc OpenAPI (Swagger UI)
- Lombok
- JUnit + Testcontainers

## API Architecture

- `GET /api/**` - public read-only API for iOS
- `/admin/**` - write API, `ADMIN` role only
- `/auth/**` - authentication (`POST /auth/login` in current version)

## Quick Start

### 1) Requirements

- JDK 21
- PostgreSQL (local or Docker)

### 2) Configuration

Defaults are in `src/main/resources/application.yml`:

- DB URL: `jdbc:postgresql://localhost:5432/kpfl`
- DB user/password: `postgres/postgres`
- Port: `8080`
- JWT:
  - `JWT_SECRET` (base64)
  - `JWT_ACCESS_EXPIRATION_MS` (default: `86400000`)

### 3) Start PostgreSQL (Docker example)

```bash
docker run --name kpfl-postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=kpfl -p 5432:5432 -d postgres:16
```

### 4) Run backend

Windows:

```bat
set "JAVA_HOME=C:\Users\user\.jdks\ms-21.0.8"
set "PATH=%JAVA_HOME%\bin;%PATH%"
mvnw.cmd spring-boot:run
```

Linux/macOS:

```bash
./mvnw spring-boot:run
```

Flyway migrations are applied automatically on startup.

## Swagger

- Swagger UI: `http://localhost:8080/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

## Authentication

### Admin Login

`POST /auth/login`

Request body:

```json
{
  "email": "admin@kpfl.local",
  "password": "admin"
}
```

Response:

```json
{
  "token": "<jwt>"
}
```

Use the token for admin endpoints:

```http
Authorization: Bearer <jwt>
```

## API Endpoints

### Public API (`/api/**`, no token required)

#### Clubs

- `GET /api/clubs` - list clubs
- `GET /api/clubs/{id}` - club profile + squad

#### Players

- `GET /api/players/{id}` - player details

#### Matches

- `GET /api/matches` - matches list with filters:
  - `seasonYear` (int)
  - `round` (int)
  - `clubId` (long)
  - `dateFrom` (`yyyy-MM-dd`)
  - `dateTo` (`yyyy-MM-dd`)
  - `status` (`SCHEDULED|FINISHED|POSTPONED`)
- `GET /api/matches/{id}` - match details

#### Standings

- `GET /api/standings?seasonYear=2026` - standings (calculated on-the-fly from `FINISHED` matches)

#### News

- `GET /api/news?limit=20` - news list (`limit` from 1 to 50)
- `GET /api/news/{id}` - news details

### Admin API (`/admin/**`, ADMIN only)

#### Clubs

- `POST /admin/clubs` - create club
- `PUT /admin/clubs/{id}` - update club

#### Players

- `POST /admin/players` - create player
- `PUT /admin/players/{id}` - update player

#### Matches

- `POST /admin/matches` - create match
- `PUT /admin/matches/{id}` - update match
- `POST /admin/matches/{id}/result` - set score and mark match as `FINISHED`

#### News

- `POST /admin/news` - create news
- `PUT /admin/news/{id}` - update news

## Admin Request Examples

### Create Club

```json
{
  "name": "Test Club",
  "abbr": "TST",
  "city": "Bishkek",
  "stadium": "Test Arena",
  "foundedYear": 2026,
  "primaryColor": "#112233",
  "logoUrl": null,
  "coachName": "Test Coach",
  "coachInfo": "Temporary coach note"
}
```

### Create Player

```json
{
  "clubId": 1,
  "firstName": "Test",
  "lastName": "Player",
  "number": 99,
  "position": "FW",
  "ageYears": 22,
  "marketValueEur": 50000,
  "sourceUrl": "https://example.com",
  "sourceNote": "manual verification"
}
```

### Create Match

```json
{
  "seasonYear": 2026,
  "roundNumber": 3,
  "dateTime": "2026-03-20T18:00:00",
  "stadium": "Central Stadium",
  "homeClubId": 1,
  "awayClubId": 2,
  "status": "SCHEDULED"
}
```

### Set Match Result

```json
{
  "homeGoals": 2,
  "awayGoals": 1
}
```

### Create News

```json
{
  "title": "Matchday update",
  "shortText": "Round 2 schedule updated.",
  "tag": "OFFICIAL",
  "publishedAt": "2026-03-11T10:00:00",
  "clubId": 1,
  "playerId": null
}
```

## Error Response Format

All API errors use a unified format:

```json
{
  "timestamp": "2026-02-26T17:01:23.000Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Limit must be between 1 and 50",
  "path": "/api/news"
}
```

## Migrations and Seed Data

Migration files are in `src/main/resources/db/migration`:

- `V1__init.sql` - schema
- `V2__indexes.sql` - seed data
- `V3__indexes.sql` - indexes
- `V4__real_kpfl_seed.sql` - extended real KPFL dataset (16 clubs + player rosters)
- `V5__kpfl_historical_archive.sql` - KPFL historical archive (champions 1992-2025, club honours, 2025 table, records, all-time leaderboards)

## Tests

Linux/macOS:

```bash
./mvnw test
```

Windows:

```bat
mvnw.cmd test
```

If tests rely on Testcontainers, Docker must be running.


