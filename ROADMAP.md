# FutureMirror — roadmap

## Shipped in v0.1 (source prototype)
- Flutter Windows app UI, scenario sliders, dependency map, scorecards
- Native Rust JSON-in/JSON-out simulation engine
- Identical Dart algorithm fallback for computers without Rust
- Local history, compare runs, evidence disclaimer

## Phase 2 — customizable reality model
- CRUD for nodes, edges, baseline costs and risk parameters
- Rich typed relationships: supply, capacity, demand, budget, timing
- Validate graph cycles and user-defined impact rules
- SQLite versioned model and migrations
- Import CSV/Excel with data validation

## Phase 3 — serious simulation
- Calibrated exposure models; assumption provenance
- Monte Carlo distributions with repeatable random seeds
- Sensitivity analysis and uncertainty bounds
- Resource scheduling and discrete-event modeling
- Backtesting predictions against observed outcomes

## Phase 4 — product workflows
- Scenario collections, annotated decisions, export PDF/CSV
- Timeline animation and Sankey/path explanations
- Interactive dependency editor and node inspector
- Local encrypted data vault / user access controls
- Guided onboarding and real samples

## Phase 5 — optional intelligence
- Optional Ollama local LLM for plain-language scenario reports
- AI suggestions labeled as hypotheses, never source facts
- Offline retrieval grounded in imported organizational documentation
- Plugin SDK and sandboxed custom models

## Phase 6 — deployment and collaboration
- Windows installer, signed builds, update mechanism
- Cross-platform builds, portable project archives
- Optional self-hosted collaboration, audit logs and role controls
- Performance benchmarks and automated CI builds

The application is a demonstrator: do not imply quantitative validity without calibration and validation.
