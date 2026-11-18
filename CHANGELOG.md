# Changelog

All notable changes to FutureMirror are documented in this file.

The project follows [Semantic Versioning](https://semver.org/).

## Unreleased

### Added

- Exact operational-model snapshots inside newly saved simulation runs
- Drag-to-arrange system positioning on the Reality Map
- Backward-compatible loading for history created before model snapshots
- Persistent operational-model editor for systems, categories, costs, risks, and dependencies
- Add, edit, delete, validate, and reset workflows for the operational graph
- Custom-model simulation and model-validation test coverage
- CSV export for the active scenario and its ranked system impacts
- Automatic Windows analysis, test, Rust test, and release-build workflow
- Undo action after deleting a saved simulation
- Responsive dashboard regression coverage
- Saved-history serialization and CSV escaping tests

### Changed

- Native engine discovery now works from both the source directory and a packaged executable directory
- Saved history now uses a temporary file and backup before replacement
- Native-engine failures and timeouts are reported in the fallback result warnings
- Metric cards and scenario controls adapt more reliably to medium window sizes

### Fixed

- Dart type mismatch that prevented the original Windows build
- Scenario-name synchronization when resetting or loading a run
- Broken generated counter test

## 0.1.0 - 2026-11-18

### Added

- Native Flutter Windows dashboard
- Scenario laboratory with five disruption controls
- Dependency reality map
- Saved-run comparison and local history
- Optional Rust simulation engine with deterministic Dart fallback
- Model evidence and limitations view
