import 'dart:convert';
import 'dart:io';
import 'dart:math';

class Scenario {
  String name;
  double staffAbsence, supplierDelay, demandSpike, itOutage, cashPressure;
  int horizonDays;
  Scenario(
      {this.name = 'Operational Stress Test',
      this.staffAbsence = .25,
      this.supplierDelay = .40,
      this.demandSpike = .20,
      this.itOutage = .10,
      this.cashPressure = .22,
      this.horizonDays = 30});
  Map<String, dynamic> toJson() => {
        'name': name,
        'staffAbsence': staffAbsence,
        'supplierDelay': supplierDelay,
        'demandSpike': demandSpike,
        'itOutage': itOutage,
        'cashPressure': cashPressure,
        'horizonDays': horizonDays
      };
  factory Scenario.fromJson(Map<String, dynamic> j) => Scenario(
      name: j['name'] ?? 'Scenario',
      staffAbsence: (j['staffAbsence'] ?? 0).toDouble(),
      supplierDelay: (j['supplierDelay'] ?? 0).toDouble(),
      demandSpike: (j['demandSpike'] ?? 0).toDouble(),
      itOutage: (j['itOutage'] ?? 0).toDouble(),
      cashPressure: (j['cashPressure'] ?? 0).toDouble(),
      horizonDays: (j['horizonDays'] ?? 30) as int);
  Scenario copy() => Scenario.fromJson(toJson());
}

class MirrorNode {
  final String id, label, category;
  final double baselineCost, baselineRisk, x, y;
  const MirrorNode(this.id, this.label, this.category, this.baselineCost,
      this.baselineRisk, this.x, this.y);
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'category': category,
        'baselineCost': baselineCost,
        'baselineRisk': baselineRisk,
        'x': x,
        'y': y
      };
}

class MirrorEdge {
  final String from, to;
  final double strength;
  const MirrorEdge(this.from, this.to, this.strength);
  Map<String, dynamic> toJson() =>
      {'from': from, 'to': to, 'strength': strength};
}

const nodes = <MirrorNode>[
  MirrorNode('team', 'Workforce', 'People', 17000, .12, .19, .26),
  MirrorNode('suppliers', 'Supply chain', 'Supply', 25000, .17, .47, .13),
  MirrorNode('systems', 'IT systems', 'Technology', 12000, .09, .80, .25),
  MirrorNode(
      'delivery', 'Service delivery', 'Operations', 31000, .16, .49, .47),
  MirrorNode('customers', 'Customer trust', 'Customers', 14500, .12, .83, .69),
  MirrorNode('cash', 'Cash position', 'Finance', 27000, .19, .16, .77),
  MirrorNode(
      'capacity', 'Resource capacity', 'Operations', 18000, .14, .22, .52),
  MirrorNode('quality', 'Quality control', 'Operations', 11000, .11, .56, .81),
];
const edges = <MirrorEdge>[
  MirrorEdge('team', 'capacity', .9),
  MirrorEdge('team', 'quality', .55),
  MirrorEdge('suppliers', 'delivery', .88),
  MirrorEdge('suppliers', 'cash', .42),
  MirrorEdge('systems', 'delivery', .81),
  MirrorEdge('systems', 'quality', .57),
  MirrorEdge('capacity', 'delivery', .91),
  MirrorEdge('delivery', 'customers', .94),
  MirrorEdge('quality', 'customers', .77),
  MirrorEdge('cash', 'suppliers', .46),
  MirrorEdge('customers', 'cash', .39),
];

class NodeImpact {
  final String id, label, category;
  final double score, baselineRisk, projectedRisk, extraCost, delayDays;
  final List<String> reasons;
  NodeImpact(this.id, this.label, this.category, this.score, this.baselineRisk,
      this.projectedRisk, this.extraCost, this.delayDays, this.reasons);
  factory NodeImpact.fromJson(Map<String, dynamic> j) => NodeImpact(
      j['id'],
      j['label'],
      j['category'],
      (j['score'] as num).toDouble(),
      (j['baselineRisk'] as num).toDouble(),
      (j['projectedRisk'] as num).toDouble(),
      (j['extraCost'] as num).toDouble(),
      (j['delayDays'] as num).toDouble(),
      List<String>.from(j['reasons']));
}

class SimulationResult {
  final String engine;
  final double totalExtraCost, avgProjectedRisk, maxDelayDays;
  final int affectedCount;
  final List<NodeImpact> impacts;
  final List<String> warnings;
  SimulationResult(this.engine, this.totalExtraCost, this.avgProjectedRisk,
      this.maxDelayDays, this.affectedCount, this.impacts, this.warnings);
  factory SimulationResult.fromJson(Map<String, dynamic> j) => SimulationResult(
      j['engine'],
      (j['totalExtraCost'] as num).toDouble(),
      (j['avgProjectedRisk'] as num).toDouble(),
      (j['maxDelayDays'] as num).toDouble(),
      j['affectedCount'],
      (j['impacts'] as List)
          .map((e) => NodeImpact.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      List<String>.from(j['warnings']));
  Map<String, dynamic> toJson() => {
        'engine': engine,
        'totalExtraCost': totalExtraCost,
        'avgProjectedRisk': avgProjectedRisk,
        'maxDelayDays': maxDelayDays,
        'affectedCount': affectedCount,
        'impacts': impacts
            .map((i) => {
                  'id': i.id,
                  'label': i.label,
                  'category': i.category,
                  'score': i.score,
                  'baselineRisk': i.baselineRisk,
                  'projectedRisk': i.projectedRisk,
                  'extraCost': i.extraCost,
                  'delayDays': i.delayDays,
                  'reasons': i.reasons
                })
            .toList(),
        'warnings': warnings
      };
}

class Simulator {
  static Future<SimulationResult> run(Scenario s) async {
    final payload = jsonEncode({
      'scenario': s.toJson(),
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList()
    });
    final path =
        '${Directory.current.path}${Platform.pathSeparator}engine${Platform.pathSeparator}target${Platform.pathSeparator}release${Platform.pathSeparator}futuremirror_engine${Platform.isWindows ? '.exe' : ''}';
    try {
      if (File(path).existsSync()) {
        final process = await Process.start(path, [],
            workingDirectory: Directory.current.path);
        process.stdin.write(payload);
        await process.stdin.close();
        final outFuture = process.stdout.transform(utf8.decoder).join();
        final errFuture = process.stderr.transform(utf8.decoder).join();
        final exit = await process.exitCode.timeout(const Duration(seconds: 8),
            onTimeout: () {
          process.kill();
          return -1;
        });
        final out = await outFuture;
        final err = await errFuture;
        if (exit != 0) throw StateError(err);
        return SimulationResult.fromJson(jsonDecode(out));
      }
    } catch (_) {/* deterministic Dart engine is the offline fallback */}
    return _runInDart(s);
  }

  static SimulationResult _runInDart(Scenario s) {
    final signals = [
      s.staffAbsence,
      s.supplierDelay,
      s.demandSpike,
      s.itOutage,
      s.cashPressure
    ];
    const exposure = <String, List<double>>{
      'People': [1, .12, .24, .22, .13],
      'Supply': [.15, 1, .40, .12, .38],
      'Technology': [.08, .10, .28, 1, .10],
      'Finance': [.08, .25, .45, .18, 1],
      'Customers': [.13, .26, .85, .31, .16],
      'Operations': [.68, .71, .56, .75, .37]
    };
    const labels = [
      'Staff shortage',
      'Supplier disruption',
      'Demand surge',
      'IT interruption',
      'Cash constraint'
    ];
    final reasons = List.generate(nodes.length, (_) => <String>[]);
    final direct = List<double>.filled(nodes.length, 0);
    for (var i = 0; i < nodes.length; i++) {
      var survival = 1.0;
      for (var j = 0; j < 5; j++) {
        final contribution =
            signals[j].clamp(0.0, 1.0) * exposure[nodes[i].category]![j] * .64;
        survival *= 1 - contribution;
        if (contribution >= .095) reasons[i].add(labels[j]);
      }
      direct[i] = (1 - survival).clamp(0.0, 1.0);
    }
    var scores = List<double>.of(direct);
    for (var cycle = 0; cycle < 5; cycle++) {
      final next = List<double>.of(direct);
      for (final e in edges) {
        final a = nodes.indexWhere((n) => n.id == e.from),
            b = nodes.indexWhere((n) => n.id == e.to);
        if (a < 0 || b < 0) continue;
        final contribution = scores[a] * e.strength.clamp(0.0, 1.0) * .33;
        next[b] = 1 - (1 - next[b]) * (1 - contribution);
      }
      scores = next.map((e) => e.clamp(0.0, 1.0)).toList();
    }
    final horizon = max(.1, s.horizonDays / 30);
    final impacts = <NodeImpact>[];
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i], score = scores[i];
      if (score > direct[i] + .04) {
        reasons[i].add('Downstream dependency exposure');
      }
      if (reasons[i].isEmpty) reasons[i].add('Low modeled exposure');
      impacts.add(NodeImpact(
          n.id,
          n.label,
          n.category,
          (score * 10000).round() / 10000,
          (n.baselineRisk),
          (n.baselineRisk + (1 - n.baselineRisk) * score)
              .clamp(0, 1)
              .toDouble(),
          (n.baselineCost * score * horizon * .42).roundToDouble(),
          ((score * horizon * 8 * (n.category == 'Operations' ? 1.4 : 1)) * 10)
                  .round() /
              10,
          reasons[i]));
    }
    impacts.sort((a, b) => b.score.compareTo(a.score));
    return SimulationResult(
        'Dart fallback v0.1',
        impacts.fold(0, (v, i) => v + i.extraCost),
        impacts.fold(0.0, (v, i) => v + i.projectedRisk) / nodes.length,
        impacts.map((i) => i.delayDays).reduce(max),
        impacts.where((i) => i.score >= .12).length,
        impacts, [
      'Outputs are illustrative scenario calculations, not forecasts or financial advice.',
      'Risk and cost coefficients are demonstrative; calibrate with historical data before operational use.'
    ]);
  }
}

class SavedRun {
  final DateTime timestamp;
  final Scenario scenario;
  final SimulationResult result;
  SavedRun(this.timestamp, this.scenario, this.result);
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'scenario': scenario.toJson(),
        'result': result.toJson()
      };
  factory SavedRun.fromJson(Map<String, dynamic> j) => SavedRun(
      DateTime.parse(j['timestamp']),
      Scenario.fromJson(Map<String, dynamic>.from(j['scenario'])),
      SimulationResult.fromJson(Map<String, dynamic>.from(j['result'])));
}

class LocalStore {
  static File get file {
    final root = Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return File(
        '$root${Platform.pathSeparator}FutureMirror${Platform.pathSeparator}runs.json');
  }

  static Future<List<SavedRun>> load() async {
    try {
      if (!await file.exists()) return [];
      final json = jsonDecode(await file.readAsString()) as List;
      return json
          .map((e) => SavedRun.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<SavedRun> runs) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
        const JsonEncoder.withIndent('  ')
            .convert(runs.map((e) => e.toJson()).toList()),
        flush: true);
  }
}
