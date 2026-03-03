# Holi Ka Dahan – Burn & Release

Three-screen ritual experience:
- Greeting with soft Apple-like entrance.
- Write the habit/quality to release.
- Burning animation with fire glow, message, and quick rating.

## Run locally
1) Ensure Flutter SDK is installed (tested with `flutter --version` after brew install).
2) Install deps: `flutter pub get`
3) Run on web: `flutter run -d chrome`
4) Run on iOS simulator: `flutter run -d ios`
5) Run on Android emulator: `flutter run -d emulator-5554`
	- Physical Android device: `ANDROID_SDK_ROOT=$HOME/Library/Android/sdk ANDROID_HOME=$HOME/Library/Android/sdk flutter run -d <deviceId>`

## Build artifacts
- Web release: `flutter build web`
- Android APK: `flutter build apk --release`
- iOS (requires Xcode setup): `flutter build ios --release`

## Notes
- All logic is client-side; no backend.
- Typography via `google_fonts` (Plus Jakarta Sans); theme seeded with deep orange for fire vibes.
- Fire sound: place a short crackle at `assets/audio/fire_crackle.mp3` (update with your own). The app will skip sound if the file is missing.
