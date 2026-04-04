# Mrasem Admin (Next.js + Supabase)

Admin panel for restaurants, activities, season events, cars, bookings, and app users.

## Setup

1. Apply SQL migrations in [../supabase/migrations](../supabase/migrations) via Supabase SQL Editor or [Supabase CLI](https://supabase.com/docs/guides/cli).
2. In Supabase Dashboard → **Authentication** → **Users**, create an admin user (email + password).
3. Copy `.env.example` to `.env.local` and set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from **Project Settings → API**.

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000), sign in with the admin user.

## Deploy on Vercel (no local `npm run dev`)

1. Push the repo to GitHub (or GitLab / Bitbucket).
2. In [Vercel](https://vercel.com) → **Add New Project** → import that repo.
3. **Root Directory**: set to `mrasem-admin-next` (the Mrasem repo is a monorepo; Vercel must build this folder).
4. **Environment Variables** (Production + Preview):
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://fltfmcqfoftzjhxxpsss.supabase.co` (or your project URL)
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = anon key from Supabase → **Project Settings → API**
5. Deploy. Your admin URL will be `https://<project>.vercel.app` (or a custom domain).

**Supabase Auth (production URL)**  
Supabase Dashboard → **Authentication** → **URL Configuration**:

- **Site URL**: `https://<your-project>.vercel.app`
- **Redirect URLs**: add `https://<your-project>.vercel.app/**` (and preview URLs like `https://*.vercel.app/**` if you use Preview deployments)

Without this, login cookies/session can break on the deployed domain.

`vercel.json` sets **region** `fra1` (Frankfurt) to sit near your Supabase project (`eu-central-1`); change in `vercel.json` if you prefer another region.

## iOS / PostgREST

See [../supabase/README.md](../supabase/README.md) for how the mobile app should call Supabase and known limitations (pagination shape, bookings read path).
