# PDF Scanner

A private, on-device Flutter document studio for Android and iOS. Scan, crop, enhance, convert, merge, split, compress, preview, and share PDFs without an account or a backend.

## Design

The visual language is adapted from [Paper Bliss Scan](https://paper-bliss-scan.lovable.app) for mobile: dark/light studio surfaces, cyan actions, paper cards, and a floating scan control.

## Stack

- Flutter + Dart
- Local storage only (`SharedPreferences` + app documents)
- Camera + gallery import
- On-device crop, perspective correction, and filters
- Local PDF generation and tools
- Native share sheet
- AdMob banners and occasional interstitials after saves

## Setup

1. Install Flutter and add it to `PATH`.
2. From this folder:

```bash
flutter pub get
flutter run
```

Replace the Google test AdMob IDs in `lib/core/constants.dart`, `android/app/src/main/AndroidManifest.xml`, and `ios/Runner/Info.plist` before a store release.

## Permissions

- Camera for document capture
- Photos/storage for gallery and file import
- Internet only for ads

All document processing stays on the device.
