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
  factory MirrorNode.fromJson(Map<String, dynamic> json) => MirrorNode(
      json['id'],
      json['label'],
      json['category'],
      (json['baselineCost'] as num).toDouble(),
      (json['baselineRisk'] as num).toDouble(),
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble());
  MirrorNode copyWith(
          {String? label,
          String? category,
          double? baselineCost,
          double? baselineRisk,
          double? x,
          double? y}) =>
      MirrorNode(
          id,
          label ?? this.label,
          category ?? this.category,
          baselineCost ?? this.baselineCost,
          baselineRisk ?? this.baselineRisk,
          x ?? this.x,
          y ?? this.y);
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
  factory MirrorEdge.fromJson(Map<String, dynamic> json) => MirrorEdge(
      json['from'], json['to'], (json['strength'] as num).toDouble());
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
  static List<String> get _engineCandidates {
    final executableDirectory = File(Platform.resolvedExecutable).parent.path;
    final relative = [
      'engine',
      'target',
      'release',
      'futuremirror_engine${Platform.isWindows ? '.exe' : ''}'
    ].join(Platform.pathSeparator);
    return {
      '${Directory.current.path}${Platform.pathSeparator}$relative',
      '$executableDirectory${Platform.pathSeparator}$relative',
    }.toList();
  }

  static Future<SimulationResult> run(Scenario s,
      {List<MirrorNode>? modelNodes, List<MirrorEdge>? modelEdges}) async {
    final activeNodes = modelNodes ?? nodes;
    final activeEdges = modelEdges ?? edges;
    if (activeNodes.isEmpty) {
      throw ArgumentError(
          'The operational model must contain at least one system.');
    }
    final payload = jsonEncode({
      'scenario': s.toJson(),
      'nodes': activeNodes.map((e) => e.toJson()).toList(),
      'edges': activeEdges.map((e) => e.toJson()).toList()
    });
    String? nativeFailure;
    try {
      final path = _engineCandidates.firstWhere(
        (candidate) => File(candidate).existsSync(),
        orElse: () => '',
      );
      if (path.isNotEmpty) {
        final process = await Process.start(path, [],
            workingDirectory: File(path).parent.path);
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
        if (exit != 0) {
          throw StateError(
              exit == -1 ? 'Native engine timed out.' : err.trim());
        }
        return SimulationResult.fromJson(jsonDecode(out));
      }
    } catch (error) {
      nativeFailure = error.toString();
    }
    final fallback = _runInDart(s, activeNodes, activeEdges);
    if (nativeFailure != null) {
      fallback.warnings.insert(
          0, 'Native engine unavailable; Dart fallback used: $nativeFailure');
    }
    return fallback;
  }

  static SimulationResult _runInDart(
      Scenario s, List<MirrorNode> activeNodes, List<MirrorEdge> activeEdges) {
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
    final reasons = List.generate(activeNodes.length, (_) => <String>[]);
    final direct = List<double>.filled(activeNodes.length, 0);
    for (var i = 0; i < activeNodes.length; i++) {
      var survival = 1.0;
      for (var j = 0; j < 5; j++) {
        final categoryExposure =
            exposure[activeNodes[i].category] ?? exposure['Operations']!;
        final contribution =
            signals[j].clamp(0.0, 1.0) * categoryExposure[j] * .64;
        survival *= 1 - contribution;
        if (contribution >= .095) reasons[i].add(labels[j]);
      }
      direct[i] = (1 - survival).clamp(0.0, 1.0);
    }
    var scores = List<double>.of(direct);
    for (var cycle = 0; cycle < 5; cycle++) {
      final next = List<double>.of(direct);
      for (final e in activeEdges) {
        final a = activeNodes.indexWhere((n) => n.id == e.from),
            b = activeNodes.indexWhere((n) => n.id == e.to);
        if (a < 0 || b < 0) continue;
        final contribution = scores[a] * e.strength.clamp(0.0, 1.0) * .33;
        next[b] = 1 - (1 - next[b]) * (1 - contribution);
      }
      scores = next.map((e) => e.clamp(0.0, 1.0)).toList();
    }
    final horizon = max(.1, s.horizonDays / 30);
    final impacts = <NodeImpact>[];
    for (var i = 0; i < activeNodes.length; i++) {
      final n = activeNodes[i], score = scores[i];
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
        impacts.fold(0.0, (v, i) => v + i.projectedRisk) / activeNodes.length,
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
  final OperationalModel? model;
  SavedRun(this.timestamp, this.scenario, this.result, [this.model]);
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'scenario': scenario.toJson(),
        'result': result.toJson(),
        if (model != null) 'model': model!.toJson()
      };
  factory SavedRun.fromJson(Map<String, dynamic> j) => SavedRun(
      DateTime.parse(j['timestamp']),
      Scenario.fromJson(Map<String, dynamic>.from(j['scenario'])),
      SimulationResult.fromJson(Map<String, dynamic>.from(j['result'])),
      j['model'] == null
          ? null
          : OperationalModel.fromJson(Map<String, dynamic>.from(j['model'])));
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
    for (final candidate in [file, File('${file.path}.backup')]) {
      try {
        if (await candidate.exists()) {
          return decode(await candidate.readAsString());
        }
      } catch (_) {
        // Try the backup before returning an empty history.
      }
    }
    return [];
  }

  static Future<void> save(List<SavedRun> runs) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.temporary');
    final backup = File('${file.path}.backup');
    await temporary.writeAsString(encode(runs), flush: true);
    if (await file.exists()) {
      await file.copy(backup.path);
      await file.delete();
    }
    await temporary.rename(file.path);
  }

  static String encode(List<SavedRun> runs) =>
      const JsonEncoder.withIndent('  ')
          .convert(runs.map((e) => e.toJson()).toList());

  static List<SavedRun> decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Saved history must be a JSON list.');
    }
    return decoded
        .map((e) => SavedRun.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

OperationalModel _defaultOperationalModel() =>
    OperationalModel(List.of(nodes), List.of(edges));

class OperationalModel {
  final List<MirrorNode> nodes;
  final List<MirrorEdge> edges;
  OperationalModel(this.nodes, this.edges);

  factory OperationalModel.defaults() => _defaultOperationalModel();

  factory OperationalModel.fromJson(Map<String, dynamic> json) {
    final loadedNodes = (json['nodes'] as List)
        .map((item) => MirrorNode.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    if (loadedNodes.isEmpty) {
      throw const FormatException(
          'An operational model needs at least one system.');
    }
    final ids = loadedNodes.map((node) => node.id).toSet();
    if (ids.length != loadedNodes.length) {
      throw const FormatException('System identifiers must be unique.');
    }
    if (loadedNodes.any((node) =>
        node.id.trim().isEmpty ||
        node.label.trim().isEmpty ||
        node.baselineCost < 0 ||
        node.baselineRisk < 0 ||
        node.baselineRisk > 1)) {
      throw const FormatException(
          'Systems need an identifier, name, non-negative cost, and risk from 0 to 1.');
    }
    final relationships = <String>{};
    final loadedEdges = (json['edges'] as List)
        .map((item) => MirrorEdge.fromJson(Map<String, dynamic>.from(item)))
        .where((edge) =>
            edge.from != edge.to &&
            ids.contains(edge.from) &&
            ids.contains(edge.to) &&
            edge.strength >= 0 &&
            edge.strength <= 1 &&
            relationships.add('${edge.from}\u0000${edge.to}'))
        .toList();
    return OperationalModel(loadedNodes, loadedEdges);
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': 1,
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'edges': edges.map((edge) => edge.toJson()).toList()
      };
}

class OperationalModelStore {
  static File get file {
    final root = Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return File(
        '$root${Platform.pathSeparator}FutureMirror${Platform.pathSeparator}model.json');
  }

  static Future<OperationalModel> load() async {
    try {
      if (!await file.exists()) return OperationalModel.defaults();
      return OperationalModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(await file.readAsString())));
    } catch (_) {
      return OperationalModel.defaults();
    }
  }

  static Future<void> save(OperationalModel model) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.temporary');
    await temporary.writeAsString(
        const JsonEncoder.withIndent('  ').convert(model.toJson()),
        flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }
}

class SimulationExporter {
  static Future<File> saveCsv(SavedRun run) async {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    final directory = Directory(
        '$home${Platform.pathSeparator}Documents${Platform.pathSeparator}FutureMirror Exports');
    await directory.create(recursive: true);
    final safeName = run.scenario.name
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final stamp = run.timestamp
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final output = File(
        '${directory.path}${Platform.pathSeparator}${safeName.isEmpty ? 'scenario' : safeName}_$stamp.csv');
    await output.writeAsString(toCsv(run), flush: true);
    return output;
  }

  static String toCsv(SavedRun run) {
    String cell(Object? value) => '"${value.toString().replaceAll('"', '""')}"';
    final rows = <List<Object?>>[
      ['FutureMirror scenario export'],
      ['Scenario', run.scenario.name],
      ['Timestamp', run.timestamp.toIso8601String()],
      ['Horizon days', run.scenario.horizonDays],
      ['Engine', run.result.engine],
      ['Model systems', run.model?.nodes.length ?? 'Legacy run'],
      ['Model dependencies', run.model?.edges.length ?? 'Legacy run'],
      ['Total extra cost', run.result.totalExtraCost],
      ['Average projected risk', run.result.avgProjectedRisk],
      ['Maximum delay days', run.result.maxDelayDays],
      [],
      [
        'System',
        'Category',
        'Impact score',
        'Projected risk',
        'Extra cost',
        'Delay days',
        'Reasons'
      ],
      ...run.result.impacts.map((impact) => [
            impact.label,
            impact.category,
            impact.score,
            impact.projectedRisk,
            impact.extraCost,
            impact.delayDays,
            impact.reasons.join('; ')
          ])
    ];
    return '${rows.map((row) => row.map(cell).join(',')).join('\r\n')}\r\n';
  }
}
