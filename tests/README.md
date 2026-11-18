# Validation

Rust engine: run `cargo test` inside `engine` after installing Rust/Cargo.
Flutter UI: run `flutter analyze` and `flutter test` after installing Flutter.

Every push is verified on Windows by GitHub Actions with Dart analysis, Flutter unit and widget tests, Rust tests, a release build, and portable-package creation. The optional Dart fallback lets the application launch even if Rust has not been compiled locally.
