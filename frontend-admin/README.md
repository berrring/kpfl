# Frontend Admin

`frontend-admin` is the web admin client for KPFL.

It is a React 19 + Vite application that talks to the backend API and is intended for editors/admins, not end users.

## What It Covers

- admin login with JWT
- clubs management
- players management
- matches management
- news management
- fantasy admin operations:
  - leagues overview
  - fantasy teams overview
  - player match stats
  - fantasy price rebuild
  - round recalculation

## Routes

- `/admin/login`
- `/admin/clubs`
- `/admin/clubs/:id`
- `/admin/players`
- `/admin/matches`
- `/admin/news`
- `/admin/fantasy`

## Local Development

```bash
npm ci
npm run dev
```

Default dev URL:

- `http://localhost:5173/admin/login`

## API Connectivity

Default API base:

- `/backend`

Why:

- the app is designed to work behind a same-origin proxy
- in local Vite dev/preview, `/backend/*` is proxied to Render
- in Vercel, `/backend/*` can be rewritten to the backend origin

Environment override:

```env
VITE_API_BASE_URL=/backend
```

If you want to call a different backend directly:

```env
VITE_API_BASE_URL=http://localhost:8080
```

## Build

```bash
npm run build
```

The current production build succeeds locally.

## Current Admin Account

- email: `admin@kpfl.local`
- password: `admin`

## Notes

- this app uses a lightweight custom router instead of React Router
- backend responses are normalized on the frontend because not every endpoint returns the exact same shape
- if you open the built files without proxy/rewrite support, API requests will fail

## Deployment

Recommended target:

- Vercel

See:

- `DEPLOY_VERCEL.md`
- `vercel.json`
