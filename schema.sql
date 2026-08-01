-- =====================================================================
--  Vereinsrangliste Maintal — Datenbank-Schema (Phase 1)
--  Spieler · Mitgliedschafts-Status · Einstellungen · Turnierleiter
--
--  Ausführen: Supabase → SQL Editor → New query → einfügen → Run.
--  Kann bei Bedarf mehrfach ausgeführt werden (idempotent).
-- =====================================================================

create extension if not exists "uuid-ossp";

-- ---------------------------------------------------------------------
--  Turnierleiter-Profile (verknüpft mit Supabase Auth)
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  full_name  text,
  role       text not null default 'director' check (role in ('admin','director')),
  created_at timestamptz not null default now()
);

-- Legt automatisch ein Profil an, sobald sich ein Turnierleiter registriert.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
--  Mitgliedschafts-Status (selbst definierbar in den Einstellungen)
-- ---------------------------------------------------------------------
create table if not exists public.membership_status (
  id         uuid primary key default uuid_generate_v4(),
  name       text not null unique,
  color      text not null default '#005CC8',
  sort_order int  not null default 0,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
--  Spieler (Vereinsmitglieder & Gastspieler)
-- ---------------------------------------------------------------------
create table if not exists public.players (
  id                   uuid primary key default uuid_generate_v4(),
  player_number        text unique,        -- deine frei vergebbare Spieler-ID
  first_name           text not null,
  last_name            text not null,
  membership_status_id uuid references public.membership_status(id) on delete set null,
  email                text,
  phone                text,
  birth_date           date,
  gender               text check (gender in ('m','w','d') or gender is null),
  notes                text,
  is_active            boolean not null default true,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index if not exists players_status_idx on public.players(membership_status_id);
create index if not exists players_name_idx   on public.players(last_name, first_name);

-- updated_at automatisch pflegen
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists players_updated_at on public.players;
create trigger players_updated_at before update on public.players
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
--  App-Einstellungen (Key-Value, z. B. Ranglisten-PDF-Link)
-- ---------------------------------------------------------------------
create table if not exists public.app_settings (
  key        text primary key,
  value      jsonb,
  updated_at timestamptz not null default now()
);

insert into public.app_settings (key, value)
values ('ranking_pdf_url', '""'::jsonb)
on conflict (key) do nothing;

-- ---------------------------------------------------------------------
--  Zugriffsschutz (Row Level Security)
--  Nur eingeloggte Turnierleiter dürfen die Verwaltungstabellen sehen/ändern.
-- ---------------------------------------------------------------------
alter table public.profiles          enable row level security;
alter table public.membership_status enable row level security;
alter table public.players           enable row level security;
alter table public.app_settings      enable row level security;

drop policy if exists "profiles read"        on public.profiles;
drop policy if exists "profiles update self"  on public.profiles;
drop policy if exists "status all"            on public.membership_status;
drop policy if exists "players all"           on public.players;
drop policy if exists "settings all"          on public.app_settings;

create policy "profiles read" on public.profiles
  for select to authenticated using (true);
create policy "profiles update self" on public.profiles
  for update to authenticated using (auth.uid() = id);

create policy "status all" on public.membership_status
  for all to authenticated using (true) with check (true);
create policy "players all" on public.players
  for all to authenticated using (true) with check (true);
create policy "settings all" on public.app_settings
  for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
--  Start-Beispiele (kannst du in den Einstellungen ändern/löschen)
-- ---------------------------------------------------------------------
insert into public.membership_status (name, color, sort_order) values
  ('Vollmitglied', '#2E7D4F', 1),
  ('Jugend',       '#005CC8', 2),
  ('Passiv',       '#8A8A8A', 3),
  ('Gastspieler',  '#C4732F', 4)
on conflict (name) do nothing;
