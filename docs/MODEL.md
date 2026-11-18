# Model specification v0.1

This is an **illustrative impact propagation heuristic**, not an empirical prediction system.

## Inputs
Scenario has five normalized 0–1 stress values: staff absence, supplier delay, demand spike, IT outage, cash pressure; plus time horizon (7, 30, 90 days).

Each example node has a name, category, baseline monthly cost in *illustrative USD*, and baseline risk index 0–1. Directed edges have a strength value 0–1. All example values were invented for demonstration.

## Algorithm
For node i and stress source j, contribution c_ij = stress_j × categoryExposure_ij × 0.64.
Direct impact d_i = 1 − product(1 − c_ij) over five stress sources.

Iterate five times, resetting each node to direct impact and applying upstream contributions across directed edges:
`next[target] = 1 - (1 - next[target]) * (1 - previous[source] * edgeStrength * 0.33)`.

Projected risk index = baselineRisk + (1 − baselineRisk) × finalImpact.

Additional illustrative cost = baselineMonthlyCost × finalImpact × max(0.1, horizonDays / 30) × 0.42.

Delay indicator = finalImpact × max(0.1, horizonDays / 30) × 8; an Operations node receives multiplier 1.4.

A node is considered affected if final impact ≥ 0.12.

## Constraints and limitations
- Feedback loops are approximated with five bounded iterations, not an equilibrium solve.
- The values are not probability estimates, confidence intervals, actual expenses or projected dates.
- Interactions are coarse category factors, not causal evidence.
- The system uses neither machine learning nor live information.
- Cost figures across nodes may double-count impacts and must not be interpreted as an accounting forecast.
- Validation, calibration, audited inputs and historical tests are prerequisite for real decisions.
