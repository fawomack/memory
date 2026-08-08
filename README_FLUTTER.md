# Flutter Setup for this repo

This file contains minimal steps to prepare your machine and run the scaffolded Flutter app.

1) Install Flutter SDK
- Follow official instructions for your OS: https://flutter.dev/docs/get-started/install
- After installing, ensure `flutter` is on your `PATH` and run:

```bash
flutter doctor
```

2) Android / iOS tooling
- Windows/Linux: Install Android Studio and the Android SDK + emulator.
- macOS: Install Xcode for iOS toolchain (if targeting iOS) and Android Studio for Android.
- Ensure platform tools are available and emulators are set up.

3) VS Code extensions
Install these recommended extensions in VS Code (shown by the workspace recommendations):
- Dart
- Flutter

4) Using this scaffold
Run from the project root:

```bash
flutter pub get
flutter run
```

You can also open the project in VS Code and use the Flutter Run/Debug options.

If `flutter doctor` reports missing items, follow its guidance to complete setup.

Questions or want me to walk you through installing the SDKs? Reply and I will guide you step-by-step.
