# Contributing to FutureMirror

FutureMirror welcomes focused improvements that preserve its local-first design and clearly distinguish illustrative modeling from validated prediction.

## Development setup

1. Install Flutter stable and Visual Studio 2022 with the Desktop development with C++ workload.
2. Optionally install the stable Rust MSVC toolchain.
3. Restore dependencies with `flutter pub get`.
4. Start the app with `flutter run -d windows`.

## Before submitting a change

Run the complete verification set:

```powershell
dart format lib test
flutter analyze
flutter test
flutter build windows --release

Set-Location engine
cargo test
```

Changes to the Dart and Rust simulation implementations should produce equivalent outputs for the same payload. Add tests for new calculations, persistence formats, and responsive UI behavior.

## Product principles

- Keep core workflows available offline.
- Do not add telemetry by default.
- Label assumptions and uncertainty clearly.
- Do not describe uncalibrated outputs as predictions.
- Avoid sending scenario data to external services.
- Preserve backward compatibility for saved local history when practical.

## Pull requests

Keep each pull request focused. Explain the user-facing outcome, list verification performed, and call out any change to the model, persistence format, privacy behavior, or packaging requirements.
