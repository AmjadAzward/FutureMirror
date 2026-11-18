import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:future_mirror/model.dart';

void main() {
  test('zero shocks produce no modeled extra cost', () async {
    final result = await Simulator.run(Scenario(
      staffAbsence: 0,
      supplierDelay: 0,
      demandSpike: 0,
      itOutage: 0,
      cashPressure: 0,
    ));
    expect(result.totalExtraCost, 0);
    expect(result.affectedCount, 0);
  });
  test('strong staff disruption increases modeled exposure', () async {
    final result = await Simulator.run(Scenario(
      staffAbsence: .9,
      supplierDelay: 0,
      demandSpike: 0,
      itOutage: 0,
      cashPressure: 0,
    ));
    expect(result.totalExtraCost, greaterThan(0));
    expect(result.impacts.first.score, greaterThan(0));
  });

  test('longer horizons increase cost and delay without changing impact score',
      () async {
    final short = await Simulator.run(Scenario(horizonDays: 7));
    final long = await Simulator.run(Scenario(horizonDays: 90));

    expect(long.totalExtraCost, greaterThan(short.totalExtraCost));
    expect(long.maxDelayDays, greaterThan(short.maxDelayDays));
    expect(long.impacts.first.score, short.impacts.first.score);
  });

  test('saved history JSON round-trips without losing scenario data', () async {
    final scenario = Scenario(name: 'Supply, demand "stress"', horizonDays: 90);
    final result = await Simulator.run(scenario);
    final original = SavedRun(DateTime.utc(2026, 11, 18), scenario, result,
        OperationalModel.defaults());

    final decoded = LocalStore.decode(LocalStore.encode([original]));

    expect(decoded, hasLength(1));
    expect(decoded.single.scenario.name, scenario.name);
    expect(decoded.single.scenario.horizonDays, 90);
    expect(decoded.single.result.totalExtraCost, result.totalExtraCost);
    expect(decoded.single.model?.nodes, hasLength(nodes.length));
    expect(decoded.single.model?.edges, hasLength(edges.length));
  });

  test('legacy saved runs without model snapshots remain compatible', () async {
    final scenario = Scenario();
    final result = await Simulator.run(scenario);
    final legacyJson = jsonEncode([
      {
        'timestamp': DateTime.utc(2026, 1, 1).toIso8601String(),
        'scenario': scenario.toJson(),
        'result': result.toJson()
      }
    ]);

    final decoded = LocalStore.decode(legacyJson);

    expect(decoded.single.model, isNull);
    expect(decoded.single.result.impacts, isNotEmpty);
  });

  test('CSV export escapes values and includes every impacted system',
      () async {
    final scenario = Scenario(name: 'Supply, demand "stress"');
    final result = await Simulator.run(scenario);
    final csv = SimulationExporter.toCsv(
        SavedRun(DateTime.utc(2026, 11, 18), scenario, result));

    expect(csv, contains('"Supply, demand ""stress"""'));
    for (final impact in result.impacts) {
      expect(csv, contains('"${impact.label}"'));
    }
  });

  test('custom operational model drives simulation output', () async {
    const customNodes = [
      MirrorNode('source', 'Custom source', 'People', 10000, .1, .2, .3),
      MirrorNode('target', 'Custom target', 'Operations', 20000, .2, .7, .6),
    ];
    const customEdges = [MirrorEdge('source', 'target', .9)];

    final result = await Simulator.run(
        Scenario(
            staffAbsence: .8,
            supplierDelay: 0,
            demandSpike: 0,
            itOutage: 0,
            cashPressure: 0),
        modelNodes: customNodes,
        modelEdges: customEdges);

    expect(result.impacts, hasLength(2));
    expect(result.impacts.map((impact) => impact.id),
        containsAll(['source', 'target']));
    expect(result.impacts.first.score, greaterThan(0));
  });

  test('operational model JSON filters invalid dependencies', () {
    final source = {
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'edges': [
        const MirrorEdge('team', 'capacity', .8).toJson(),
        const MirrorEdge('missing', 'team', .5).toJson(),
        const MirrorEdge('team', 'team', .5).toJson(),
      ]
    };

    final model = OperationalModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(jsonEncode(source))));

    expect(model.nodes, hasLength(nodes.length));
    expect(model.edges, hasLength(1));
    expect(model.edges.single.from, 'team');
    expect(model.edges.single.to, 'capacity');
  });
}
