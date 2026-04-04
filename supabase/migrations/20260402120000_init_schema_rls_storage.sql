-- Mrasem public schema: listings, app users (phone), bookings
-- RLS: anon read listings; anon insert bookings; authenticated admin full write on listings + read/update bookings

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.restaurants (
  id serial primary key,
  name text not null,
  arabic_name text not null,
  rating double precision default 0,
  cuisine text not null,
  arabic_cuisine text not null,
  image_name text,
  has_michelin boolean default false,
  description text,
  arabic_description text,
  city text not null default 'Jeddah',
  arabic_city text not null default 'جدة',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_restaurants_city on public.restaurants (city);

create table if not exists public.activities (
  id serial primary key,
  name text not null,
  rating double precision default 0,
  category text not null,
  image_name text,
  location text,
  description text,
  city text not null default 'Jeddah',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_activities_city on public.activities (city);

create table if not exists public.season_events (
  id serial primary key,
  name text not null,
  category text not null,
  image_name text,
  location text,
  description text,
  city text not null default 'Jeddah',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_season_events_city on public.season_events (city);

create table if not exists public.cars (
  id serial primary key,
  name text not null,
  category text not null,
  passengers int not null,
  image_name text,
  about text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Phone book for app (not Supabase Auth users)
create table if not exists public.users (
  id serial primary key,
  phone text unique not null,
  name text,
  created_at timestamptz default now()
);

create table if not exists public.bookings (
  id serial primary key,
  user_phone text not null,
  ticket_code text unique not null,
  place_title text not null,
  subtitle text,
  image_name text,
  date_display text,
  time_display text,
  branch text,
  qr_payload text,
  event_date timestamptz,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  uses_fork_subtitle_icon boolean default false,
  created_at timestamptz default now()
);

create index if not exists idx_bookings_user_phone on public.bookings (user_phone);
create index if not exists idx_bookings_status on public.bookings (status);
create index if not exists idx_bookings_event_date on public.bookings (event_date);

-- ---------------------------------------------------------------------------
-- Grants (Supabase API roles)
-- ---------------------------------------------------------------------------

grant usage on schema public to postgres, anon, authenticated, service_role;

grant all on all tables in schema public to postgres, anon, authenticated, service_role;
grant all on all sequences in schema public to postgres, anon, authenticated, service_role;

alter default privileges in schema public grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.restaurants enable row level security;
alter table public.activities enable row level security;
alter table public.season_events enable row level security;
alter table public.cars enable row level security;
alter table public.users enable row level security;
alter table public.bookings enable row level security;

-- Listings: public read
create policy restaurants_select_anon on public.restaurants
  for select to anon using (true);
create policy restaurants_select_auth on public.restaurants
  for select to authenticated using (true);

create policy activities_select_anon on public.activities
  for select to anon using (true);
create policy activities_select_auth on public.activities
  for select to authenticated using (true);

create policy season_events_select_anon on public.season_events
  for select to anon using (true);
create policy season_events_select_auth on public.season_events
  for select to authenticated using (true);

create policy cars_select_anon on public.cars
  for select to anon using (true);
create policy cars_select_auth on public.cars
  for select to authenticated using (true);

-- Listings: authenticated admin write
create policy restaurants_write_auth on public.restaurants
  for all to authenticated using (true) with check (true);
create policy activities_write_auth on public.activities
  for all to authenticated using (true) with check (true);
create policy season_events_write_auth on public.season_events
  for all to authenticated using (true) with check (true);
create policy cars_write_auth on public.cars
  for all to authenticated using (true) with check (true);

-- App users: admin only (no anon access)
create policy users_select_auth on public.users
  for select to authenticated using (true);
create policy users_write_auth on public.users
  for all to authenticated using (true) with check (true);

-- Bookings: mobile anon insert; admin read/update
create policy bookings_insert_anon on public.bookings
  for insert to anon with check (true);

create policy bookings_select_auth on public.bookings
  for select to authenticated using (true);
create policy bookings_update_auth on public.bookings
  for update to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------------
-- Storage: public bucket "images"
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

-- Anyone can read objects in public bucket (anon + authenticated)
create policy images_public_read on storage.objects
  for select
  using (bucket_id = 'images');

create policy images_authenticated_upload on storage.objects
  for insert to authenticated
  with check (bucket_id = 'images');

create policy images_authenticated_update on storage.objects
  for update to authenticated
  using (bucket_id = 'images')
  with check (bucket_id = 'images');

create policy images_authenticated_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'images');
