# FutureMirror — roadmap

## Shipped in v0.1 (source prototype)
- Flutter Windows app UI, scenario sliders, dependency map, scorecards
- Native Rust JSON-in/JSON-out simulation engine
- Identical Dart algorithm fallback for computers without Rust
- Local history, compare runs, evidence disclaimer

## Phase 2 — customizable reality model
- [Shipped] CRUD for nodes, edges, baseline costs and risk parameters
- [Shipped] Persistent custom operational graph with default-model reset
- [Shipped] Reproducible model snapshots attached to saved simulation runs
- [Shipped] Direct drag-to-arrange editing on the dependency canvas
- [Shipped] Versioned JSON copy/import with validation
- [Shipped] Complete workspace backup and restore
- [Shipped] Graph cycle and connectivity diagnostics
- Rich typed relationships: supply, capacity, demand, budget, timing
- [Shipped] Validate graph cycles and connectivity
- SQLite versioned model and migrations
- [Shipped] Import and export spreadsheet-compatible CSV with validation

## Phase 3 — serious simulation
- Calibrated exposure models; assumption provenance
- Monte Carlo distributions with repeatable random seeds
- [Shipped] One-at-a-time sensitivity analysis
- Uncertainty bounds and confidence intervals
- Resource scheduling and discrete-event modeling
- Backtesting predictions against observed outcomes

## Phase 4 — product workflows
- Scenario collections, annotated decisions, export PDF/CSV
- Timeline animation and Sankey/path explanations
- Interactive dependency editor and node inspector
- Local encrypted data vault / user access controls
- [Shipped] Guided onboarding and demonstration sample

## Phase 5 — optional intelligence
- Optional Ollama local LLM for plain-language scenario reports
- AI suggestions labeled as hypotheses, never source facts
- Offline retrieval grounded in imported organizational documentation
- Plugin SDK and sandboxed custom models

## Phase 6 — deployment and collaboration
- Windows installer, signed builds, update mechanism
- Cross-platform builds, portable project archives
- Optional self-hosted collaboration, audit logs and role controls
- [Shipped] Automated CI builds and portable Windows artifact
- [Shipped] Performance regression coverage for large graphs

The application is a demonstrator: do not imply quantitative validity without calibration and validation.
