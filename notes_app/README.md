# Notes App (Flutter + Supabase)

A simple notes app demonstrating email/password auth, secure per-user CRUD, persisted sessions, and client-side search. Built with Flutter, Riverpod, and Supabase.

## Tech
- Flutter 3.35.x
- Supabase (Auth + Postgres)
- Riverpod for state management

## Project structure
- `lib/main.dart` – bootstraps Supabase and env
- `lib/src/app.dart` – app theming and root navigation
- `lib/src/features/auth` – auth UI and controller
- `lib/src/features/notes` – notes model, repo, controller, UI
- `lib/src/core/providers.dart` – shared providers

## Prerequisites
- Flutter SDK installed
- Supabase project (free tier is fine)

## Environment variables
Create a `.env` file at the project root (already added to assets):
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```
You can copy `.env` from the example values above.

## Supabase setup
1) Create a new Supabase project.  
2) SQL for the `notes` table:
```sql
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc', now()),
  updated_at timestamp with time zone default timezone('utc', now()),
  user_id uuid not null references auth.users(id) on delete cascade
);

create index if not exists notes_user_id_idx on public.notes(user_id);
```

3) Enable Row Level Security:
```sql
alter table public.notes enable row level security;
```

4) Policies (owner-only access):
```sql
create policy "Users can read own notes"
  on public.notes for select
  using (auth.uid() = user_id);

create policy "Users can insert own notes"
  on public.notes for insert
  with check (auth.uid() = user_id);

create policy "Users can update own notes"
  on public.notes for update
  using (auth.uid() = user_id);

create policy "Users can delete own notes"
  on public.notes for delete
  using (auth.uid() = user_id);
```

## Running locally
```bash
flutter pub get
flutter run
```

## Building the APK (required)
```bash
flutter build apk --release
# APK output: build/app/outputs/flutter-apk/app-release.apk
```
You can also build a debug APK:
```bash
flutter build apk --debug
```

## Features
- Email/password sign up, sign in, sign out
- Session persists across app restarts (Supabase auth)
- CRUD notes with per-user isolation (RLS policies)
- Client-side search by title
- Pull-to-refresh list

## Assumptions / trade-offs
- Uses client-side search (acceptable per assignment)
- No deep error messaging for Supabase setup; shows simple SnackBars
- Offline handling not implemented; chose the search option

## Troubleshooting
- If you see “Missing configuration”, ensure `.env` exists and is added to assets in `pubspec.yaml`.
- Verify Supabase URL and anon key are correct and RLS policies are applied.
