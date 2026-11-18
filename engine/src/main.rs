use serde::{Deserialize, Serialize};
use std::io::{self, Read};

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Scenario {
    name: String,
    staff_absence: f64,
    supplier_delay: f64,
    demand_spike: f64,
    it_outage: f64,
    cash_pressure: f64,
    horizon_days: u32,
}
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Node {
    id: String,
    label: String,
    category: String,
    baseline_cost: f64,
    baseline_risk: f64,
    x: f64,
    y: f64,
}
#[derive(Clone, Debug, Serialize, Deserialize)]
struct Edge { from: String, to: String, strength: f64 }
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Request { scenario: Scenario, nodes: Vec<Node>, edges: Vec<Edge> }
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Impact {
    id: String, label: String, category: String, score: f64,
    baseline_risk: f64, projected_risk: f64, extra_cost: f64,
    delay_days: f64, reasons: Vec<String>,
}
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Response {
    engine: String,
    total_extra_cost: f64,
    avg_projected_risk: f64,
    max_delay_days: f64,
    affected_count: usize,
    confidence: String,
    impacts: Vec<Impact>,
    warnings: Vec<String>,
}
fn clamp01(v: f64) -> f64 { v.max(0.0).min(1.0) }
fn exposure(cat: &str) -> [f64; 5] {
    match cat {
        "People" => [1.0, 0.12, 0.24, 0.22, 0.13],
        "Supply" => [0.15, 1.0, 0.40, 0.12, 0.38],
        "Technology" => [0.08, 0.10, 0.28, 1.0, 0.10],
        "Finance" => [0.08, 0.25, 0.45, 0.18, 1.0],
        "Customers" => [0.13, 0.26, 0.85, 0.31, 0.16],
        "Operations" => [0.68, 0.71, 0.56, 0.75, 0.37],
        _ => [0.30, 0.30, 0.30, 0.30, 0.30],
    }
}
fn simulate(req: Request) -> Response {
    let n = req.nodes.len();
    let signals = [
        req.scenario.staff_absence, req.scenario.supplier_delay,
        req.scenario.demand_spike, req.scenario.it_outage,
        req.scenario.cash_pressure,
    ];
    let mut direct = vec![0.0; n];
    let mut reasons: Vec<Vec<String>> = vec![vec![]; n];
    let labels = ["Staff shortage", "Supplier disruption", "Demand surge", "IT interruption", "Cash constraint"];
    for (i, node) in req.nodes.iter().enumerate() {
        let exp = exposure(&node.category);
        let mut survival = 1.0;
        for j in 0..5 {
            let contribution = clamp01(signals[j]) * exp[j] * 0.64;
            survival *= 1.0 - contribution;
            if contribution >= 0.095 { reasons[i].push(labels[j].to_string()); }
        }
        direct[i] = clamp01(1.0 - survival);
    }
    let mut scores = direct.clone();
    for _ in 0..5 {
        let mut next = direct.clone();
        for edge in &req.edges {
            let source = req.nodes.iter().position(|node| node.id == edge.from);
            let target = req.nodes.iter().position(|node| node.id == edge.to);
            if let (Some(s), Some(t)) = (source, target) {
                let contribution = scores[s] * clamp01(edge.strength) * 0.33;
                next[t] = 1.0 - (1.0 - next[t]) * (1.0 - contribution);
            }
        }
        for v in &mut next { *v = clamp01(*v); }
        scores = next;
    }
    let horizon = (req.scenario.horizon_days as f64 / 30.0).max(0.1);
    let mut impacts = Vec::with_capacity(n);
    let mut total_cost = 0.0;
    let mut risk_sum = 0.0;
    let mut max_delay: f64 = 0.0;
    let mut affected = 0;
    for (i, node) in req.nodes.iter().enumerate() {
        let score = scores[i];
        let projected_risk = clamp01(node.baseline_risk + (1.0 - node.baseline_risk) * score);
        let extra_cost = node.baseline_cost.max(0.0) * score * horizon * 0.42;
        let delay = (score * horizon * 8.0 * if node.category == "Operations" { 1.4 } else { 1.0 }).max(0.0);
        if score >= 0.12 { affected += 1; }
        if score > direct[i] + 0.04 { reasons[i].push("Downstream dependency exposure".to_string()); }
        if reasons[i].is_empty() { reasons[i].push("Low modeled exposure".to_string()); }
        total_cost += extra_cost;
        risk_sum += projected_risk;
        max_delay = max_delay.max(delay);
        impacts.push(Impact {
            id: node.id.clone(), label: node.label.clone(), category: node.category.clone(),
            score: (score * 10000.0).round() / 10000.0,
            baseline_risk: node.baseline_risk, projected_risk,
            extra_cost: extra_cost.round(), delay_days: (delay * 10.0).round() / 10.0,
            reasons: reasons[i].clone(),
        });
    }
    impacts.sort_by(|a, b| b.score.total_cmp(&a.score));
    Response {
        engine: "Rust native v0.1".to_string(), total_extra_cost: total_cost.round(),
        avg_projected_risk: if n == 0 { 0.0 } else { risk_sum / n as f64 },
        max_delay_days: (max_delay * 10.0).round() / 10.0, affected_count: affected,
        confidence: "Illustrative — assumptions only".to_string(), impacts,
        warnings: vec![
            "Outputs are illustrative scenario calculations, not forecasts or financial advice.".to_string(),
            "Risk and cost sensitivity coefficients are demonstrative; calibrate with historical data before operational use.".to_string(),
        ],
    }
}
fn main() {
    let mut input = String::new();
    if let Err(err) = io::stdin().read_to_string(&mut input) {
        eprintln!("Cannot read JSON input: {err}"); std::process::exit(1);
    }
    match serde_json::from_str::<Request>(&input) {
        Ok(request) => match serde_json::to_string(&simulate(request)) {
            Ok(response) => println!("{response}"),
            Err(err) => { eprintln!("Cannot serialize result: {err}"); std::process::exit(1); }
        },
        Err(err) => { eprintln!("Invalid simulation JSON: {err}"); std::process::exit(1); }
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn zero_shocks_no_impact() {
        let result = simulate(Request {
            scenario: Scenario { name: "Baseline".into(), staff_absence: 0., supplier_delay: 0., demand_spike: 0., it_outage: 0., cash_pressure: 0., horizon_days: 30 },
            nodes: vec![Node { id: "a".into(), label: "A".into(), category: "People".into(), baseline_cost: 1000., baseline_risk: 0.1, x: 0., y: 0. }], edges: vec![],
        });
        assert_eq!(result.total_extra_cost, 0.);
        assert_eq!(result.affected_count, 0);
    }
    #[test]
    fn staff_shock_increases_risk() {
        let result = simulate(Request {
            scenario: Scenario { name: "Stress".into(), staff_absence: 0.8, supplier_delay: 0., demand_spike: 0., it_outage: 0., cash_pressure: 0., horizon_days: 30 },
            nodes: vec![Node { id: "a".into(), label: "Team".into(), category: "People".into(), baseline_cost: 1000., baseline_risk: 0.1, x: 0., y: 0. }], edges: vec![],
        });
        assert!(result.total_extra_cost > 0.);
        assert!(result.impacts[0].projected_risk > 0.1);
    }
}
