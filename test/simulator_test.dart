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

  test('operational model JSON round-trips a custom graph', () {
    final original = OperationalModel(
        const [
          MirrorNode('first', 'First system', 'Operations', 12500, .2, .3, .4),
          MirrorNode('second', 'Second system', 'Finance', 8000, .1, .6, .7),
        ],
        const [MirrorEdge('first', 'second', .75)]);

    final encoded = original.toJson();
    final decoded = OperationalModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(jsonEncode(encoded))));

    expect(encoded['schemaVersion'], 1);
    expect(decoded.nodes.map((node) => node.label),
        ['First system', 'Second system']);
    expect(decoded.edges.single.strength, .75);
  });

  test('operational model JSON rejects duplicate system identifiers', () {
    final duplicate = const MirrorNode(
        'duplicate', 'Duplicate system', 'Operations', 1000, .1, .2, .3);

    expect(
        () => OperationalModel.fromJson({
              'nodes': [duplicate.toJson(), duplicate.toJson()],
              'edges': <Map<String, dynamic>>[]
            }),
        throwsFormatException);
  });

  test('workspace archive round-trips model and history', () async {
    final scenario = Scenario(name: 'Archive test');
    final result = await Simulator.run(scenario);
    final model = OperationalModel.defaults();
    final archive = WorkspaceArchive(
        model, [SavedRun(DateTime.utc(2026, 11, 18), scenario, result, model)]);

    final restored = WorkspaceArchive.decode(archive.encode());

    expect(restored.model.nodes, hasLength(model.nodes.length));
    expect(restored.history.single.scenario.name, 'Archive test');
    expect(restored.history.single.model, isNotNull);
  });

  test('model diagnostics identify cycles and disconnected systems', () {
    final model = OperationalModel(const [
      MirrorNode('a', 'A', 'Operations', 1, .1, .1, .1),
      MirrorNode('b', 'B', 'Operations', 1, .1, .2, .2),
      MirrorNode('c', 'C', 'Operations', 1, .1, .3, .3),
    ], const [
      MirrorEdge('a', 'b', .5),
      MirrorEdge('b', 'a', .5),
    ]);

    final diagnostics = ModelDiagnostics.analyze(model);

    expect(diagnostics.cycleCount, 1);
    expect(diagnostics.disconnectedNodeIds, ['c']);
  });

  test('sensitivity analysis ranks all five stress drivers', () {
    final impacts = Simulator.sensitivity(Scenario());

    expect(impacts, hasLength(5));
    expect(impacts.map((impact) => impact.driver).toSet(), hasLength(5));
    expect(impacts.first.costChange,
        greaterThanOrEqualTo(impacts.last.costChange));
    expect(impacts.every((impact) => impact.costChange >= 0), isTrue);
  });

  test('model CSV round-trips quoted spreadsheet values', () {
    final model = OperationalModel(const [
      MirrorNode('quoted', 'Supply, "critical"', 'Supply', 1200, .2, .3, .4),
      MirrorNode('target', 'Target', 'Operations', 800, .1, .6, .7),
    ], const [
      MirrorEdge('quoted', 'target', .75)
    ]);

    final decoded = ModelCsvCodec.decode(ModelCsvCodec.encode(model));

    expect(decoded.nodes.first.label, 'Supply, "critical"');
    expect(decoded.edges.single.strength, .75);
  });

  test('large operational graph simulation completes within performance budget',
      () async {
    final largeNodes = List.generate(
        500,
        (index) => MirrorNode('node_$index', 'System $index', 'Operations',
            1000 + index.toDouble(), .1, .5, .5));
    final largeEdges = List.generate(
        499, (index) => MirrorEdge('node_$index', 'node_${index + 1}', .5));
    final stopwatch = Stopwatch()..start();

    final result = await Simulator.run(Scenario(),
        modelNodes: largeNodes, modelEdges: largeEdges);
    stopwatch.stop();

    expect(result.impacts, hasLength(500));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
