-- Add auth_id (links to Supabase Auth user) and membership_id to users table
alter table public.users
  add column if not exists auth_id uuid unique references auth.users(id),
  add column if not exists membership_id text unique;

-- Generate membership IDs for existing users that don't have one
-- Format: 10-digit number based on id + random suffix
update public.users
set membership_id = lpad((id * 1000000 + floor(random() * 999999)::int)::text, 10, '0')
where membership_id is null;

-- Make membership_id not null going forward with a default
alter table public.users
  alter column membership_id set default lpad(floor(random() * 10000000000)::bigint::text, 10, '0');

-- Function: auto-create a public.users row when a new Supabase Auth user signs up via phone
create or replace function public.handle_new_auth_user()
returns trigger as $$
begin
  insert into public.users (phone, auth_id, membership_id)
  values (
    new.phone,
    new.id,
    lpad(floor(random() * 10000000000)::bigint::text, 10, '0')
  )
  on conflict (phone) do update set auth_id = excluded.auth_id;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger: fires after a new user is created in auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

-- RLS: users can read their own row
create policy "Users read own row"
  on public.users for select
  using (auth_id = auth.uid() or auth.role() = 'authenticated');
