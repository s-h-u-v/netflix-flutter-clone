# movie_app

A new Flutter project.

## Authentication and Storage

The app now uses local SQLite storage for account authentication.

- Signup creates a local account on the device.
- Login validates against the local SQLite database.
- The active session is persisted locally, so users stay logged in until sign out.
- Passwords are stored in plain text as currently requested.

## Android Emulator Run Guide

1. Open an Android emulator from Android Studio Device Manager.
2. From project root run:

   - `flutter clean`
   - `flutter pub get`
   - `flutter run`

3. Validate the auth flow:

   - Sign up with a new account.
   - Close and reopen the app to confirm auto-login.
   - Sign out and confirm login screen is shown again.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
