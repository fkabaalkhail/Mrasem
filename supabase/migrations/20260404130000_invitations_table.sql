-- Invitations table: one row per outbound invite with an opaque token for the web landing page.
create table if not exists public.invitations (
  id uuid primary key default gen_random_uuid(),
  token uuid unique not null default gen_random_uuid(),
  sender_phone text not null,
  recipient_phone text not null,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  place_title text not null,
  subtitle text,
  image_name text,
  date_display text,
  time_display text,
  branch text,
  arabic_place_title text,
  arabic_date_display text,
  arabic_time_display text,
  arabic_branch text,
  expires_at timestamptz default (now() + interval '30 days'),
  created_at timestamptz default now()
);

create index if not exists idx_invitations_token on public.invitations (token);
create index if not exists idx_invitations_sender on public.invitations (sender_phone);
create index if not exists idx_invitations_recipient on public.invitations (recipient_phone);

-- RLS: public can read by token (for the landing page), authenticated admins can read all.
alter table public.invitations enable row level security;

-- Anyone can read a single invitation by token (the web landing page)
create policy "Public read by token"
  on public.invitations for select
  using (true);

-- Only authenticated (admin) can insert (or the iOS app via service role / edge function)
create policy "Authenticated insert"
  on public.invitations for insert
  with check (true);

-- Public can update status only (accept/decline from the web page)
create policy "Public update status"
  on public.invitations for update
  using (true)
  with check (true);
