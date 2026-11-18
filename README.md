<div align="center">

# FutureMirror 1.0

### Local-first decision simulation for Windows

[![Flutter](https://img.shields.io/badge/Flutter-Desktop-42A5F5?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Rust](https://img.shields.io/badge/Rust-Native_Engine-F97316?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Windows](https://img.shields.io/badge/Windows-Desktop-7C3AED?style=for-the-badge&logo=windows11&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge)](LICENSE)
[![Windows CI](https://img.shields.io/github/actions/workflow/status/AmjadAzward/FutureMirror/windows-ci.yml?branch=main&style=for-the-badge&label=Windows%20CI)](https://github.com/AmjadAzward/FutureMirror/actions/workflows/windows-ci.yml)

**Explore operational ripple effects before making a decision.**

FutureMirror is a native Windows laboratory for constructing disruption scenarios, tracing dependencies, and comparing modeled outcomes. It runs locally, stores history on the device, and does not require an account or cloud service.

</div>

---

## Product overview

| Area | Capability |
|---|---|
| Scenario laboratory | Model workforce, supplier, demand, technology, and cash-flow pressures |
| Reality map | Inspect relationships and drag systems to arrange the graph |
| Model editor | Add, edit, remove, copy, and import systems and weighted directional dependencies |
| Decision dashboard | Review illustrative cost, risk, delay, and affected-system indicators |
| Sensitivity analysis | Rank the marginal effect of each scenario stress driver |
| Comparison | Pin one result and compare it with another saved scenario |
| Local history | Save, load, compare, and remove simulation runs on the current computer |
| Workspace portability | Copy and restore the complete model and run history as validated JSON |
| Spreadsheet exchange | Copy or import the operational graph as CSV for Excel-compatible editing |
| Data export | Write the active scenario and ranked impacts to a portable CSV report |
| Transparent model | Review assumptions, limitations, and the active execution engine |

## Visual identity

<p align="center">
  <img alt="Deep navy" src="https://img.shields.io/badge/Deep_Navy-080D19-080D19?style=flat-square" />
  <img alt="Aqua" src="https://img.shields.io/badge/Aqua-53DDD0-53DDD0?style=flat-square" />
  <img alt="Violet" src="https://img.shields.io/badge/Violet-A59BFF-A59BFF?style=flat-square" />
  <img alt="Amber" src="https://img.shields.io/badge/Amber-FFC87C-FFC87C?style=flat-square" />
  <img alt="Coral" src="https://img.shields.io/badge/Coral-FF8495-FF8495?style=flat-square" />
</p>

## Architecture

```text
Flutter desktop interface
        |
        | JSON over standard input/output
        v
Rust simulation engine
        |
        | automatic fallback when unavailable
        v
Deterministic Dart simulation engine
        |
        v
Local JSON history in %APPDATA%\FutureMirror\runs.json
```

The optional Rust executable is launched as a local child process. No network socket or external server is involved. If the native engine is unavailable, fails, or exceeds its timeout, FutureMirror uses the corresponding Dart implementation.

## Current model

- Five scenario controls with 7, 30, and 90-day horizons
- A configurable operational graph, initially populated with eight fictional systems
- Editable weighted directional dependencies, initially populated with eleven examples
- Five rounds of downstream impact propagation
- Ranked illustrative cost, risk, delay, and impact indicators
- Deterministic local execution for reproducible scenarios
- Persistent custom models stored locally beside simulation history
- Versioned JSON model exchange through the system clipboard
- Complete versioned workspace backup and restore through the clipboard
- Live graph diagnostics for feedback loops, disconnected systems, sources, and sinks
- One-at-a-time sensitivity analysis for all five scenario drivers
- Reproducible saved runs containing the exact operational-model snapshot used at execution time

> [!IMPORTANT]
> FutureMirror v0.1 is an uncalibrated technical prototype. Its data, dependencies, and coefficients are fictional. Outputs are illustrative scenarios, not predictions, financial advice, or validated operational guidance.

## Requirements

| Requirement | Purpose | Required |
|---|---|---|
| Windows 11 or supported Windows 10 | Desktop runtime | Yes |
| Flutter stable SDK | Application build and development | Yes |
| Visual Studio 2022 with Desktop development with C++ | Native Windows toolchain | Yes |
| Rust with the MSVC toolchain | Native simulation engine | No |

Verify the toolchain:

```powershell
flutter doctor -v
flutter config --enable-windows-desktop
flutter devices
cargo --version
```

## Start the application

The simplest option is:

```powershell
.\scripts\start-windows.bat
```

The launcher creates the Windows host when necessary, builds the optional Rust engine, restores Flutter packages, and starts the desktop application.

Manual development launch:

```powershell
flutter create --platforms=windows --project-name future_mirror .
flutter pub get
flutter run -d windows
```

Build the Rust engine when Cargo is available:

```powershell
Set-Location engine
cargo build --release
Set-Location ..
```

## Build a release

```powershell
.\scripts\build-release-windows.bat
```

Flutter writes the compiled application to:

```text
build\windows\x64\runner\Release\
```

The build script also produces a self-contained portable archive at:

```text
package\FutureMirror-Windows-x64.zip
```

Keep the generated DLL files and `data` directory beside `future_mirror.exe`. If the Rust engine is packaged, preserve its expected relative path:

```text
engine\target\release\futuremirror_engine.exe
```

## Test and verify

```powershell
flutter analyze
flutter test

Set-Location engine
cargo test
```

The Flutter suite covers the deterministic simulation behavior and guards the dashboard against responsive layout regressions.

## Project structure

```text
FutureMirror/
|-- lib/
|   |-- main.dart          Desktop interface and interaction flow
|   `-- model.dart         Data models, simulation fallback, local storage
|-- engine/
|   `-- src/main.rs        Native Rust simulation engine
|-- docs/
|   `-- MODEL.md           Model assumptions and calculation details
|-- scripts/               Windows launch and release helpers
|-- test/                  Flutter unit and widget tests
|-- ROADMAP.md             Planned product phases
`-- LICENSE                MIT license
```

## Privacy

FutureMirror v0.1 includes:

- No telemetry
- No authentication
- No cloud synchronization
- No external API calls
- No monthly service dependency

Saved simulations are stored as unencrypted JSON on the current computer. Writes use a temporary file and retain a backup of the previous valid history. Avoid entering sensitive organizational information on a shared device.

## Roadmap

Planned directions include customizable dependency models, validated data import, uncertainty analysis, sensitivity testing, scenario reports, encrypted local storage, and signed Windows packaging. See [ROADMAP.md](ROADMAP.md) for the full staged plan.

## License

FutureMirror is available under the [MIT License](LICENSE). Flutter and Rust are open-source projects distributed under their respective licenses.

---

<div align="center">

**FutureMirror**

Private by design. Transparent by default. Built for careful exploration.

</div>
