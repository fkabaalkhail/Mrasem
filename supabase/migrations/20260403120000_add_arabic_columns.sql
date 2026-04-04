-- Activities: Arabic + safety fields
alter table public.activities
  add column if not exists arabic_name text not null default '',
  add column if not exists arabic_category text not null default '',
  add column if not exists arabic_description text,
  add column if not exists arabic_location text,
  add column if not exists safety_guidelines text,
  add column if not exists arabic_safety_guidelines text;

-- Season events: Arabic fields
alter table public.season_events
  add column if not exists arabic_name text not null default '',
  add column if not exists arabic_category text not null default '',
  add column if not exists arabic_description text,
  add column if not exists arabic_location text;

-- Cars: Arabic fields
alter table public.cars
  add column if not exists arabic_name text not null default '',
  add column if not exists arabic_about text,
  add column if not exists arabic_passenger_line text;
