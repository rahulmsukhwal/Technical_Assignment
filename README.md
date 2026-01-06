# Flutter Notes App (Supabase)

This repository contains a Flutter notes app that satisfies the assignment requirements: email/password auth, per-user secure CRUD via Supabase RLS, client-side search, and APK build output.

## Where to look
- App source: `notes_app/`
- Detailed setup & Supabase schema/policies: `notes_app/README.md`
- Built APKs after running builds:
  - Debug: `notes_app/build/app/outputs/flutter-apk/app-debug.apk`
  - Release: `notes_app/build/app/outputs/flutter-apk/app-release.apk`

## Quick start
```bash
cd notes_app
flutter pub get
cat <<EOF > .env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
EOF
flutter run
```

## Build APK
```bash
cd notes_app
flutter build apk --release   # or --debug
```

See `notes_app/README.md` for full instructions and the SQL to create the `notes` table and RLS policies in Supabase.
