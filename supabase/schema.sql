-- Bee Hive Lodge No. 66 attendance
-- Members sign in anonymously (insert only). Only admins can read, export or delete.

create table if not exists public.attendance (
  id            bigint generated always as identity primary key,
  meeting_date  date        not null default (now() at time zone 'America/New_York')::date,
  signed_in_at  timestamptz not null default now(),
  name          text not null check (char_length(btrim(name))  between 2 and 80),
  lodge         text not null check (char_length(btrim(lodge)) between 2 and 80),
  title         text check (title is null or char_length(title) <= 60)
);

-- One sign-in per person per lodge per day.
create unique index if not exists attendance_one_per_day
  on public.attendance (meeting_date, lower(btrim(name)), lower(btrim(lodge)));

create index if not exists attendance_by_date on public.attendance (meeting_date);

-- Email addresses allowed to view and export attendance.
create table if not exists public.admins (
  email text primary key
);

alter table public.attendance enable row level security;
alter table public.admins     enable row level security;  -- no policies: invisible to the public API

-- Kept in a schema the public API does not expose.
create schema if not exists private;
grant usage on schema private to authenticated;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admins a
    where lower(a.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

revoke all on function private.is_admin() from public, anon;
grant execute on function private.is_admin() to authenticated;

-- Anyone with the link may sign in, but may only fill name, lodge and title.
-- Date and time always come from the server.
revoke all on public.attendance from anon, authenticated;
grant insert (name, lodge, title) on public.attendance to anon, authenticated;
grant select, delete on public.attendance to authenticated;

drop policy if exists "anyone can sign in" on public.attendance;
create policy "anyone can sign in" on public.attendance
  for insert to anon, authenticated
  with check (true);

drop policy if exists "admins can read" on public.attendance;
create policy "admins can read" on public.attendance
  for select to authenticated
  using (private.is_admin());

drop policy if exists "admins can delete" on public.attendance;
create policy "admins can delete" on public.attendance
  for delete to authenticated
  using (private.is_admin());
