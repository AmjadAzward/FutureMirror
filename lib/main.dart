import 'dart:math';
// Flutter 3.50 deprecates the legacy umbrella import, but the replacement
// package is not yet exposed as a direct SDK dependency to applications.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FutureMirrorApp());
}

const bg = Color(0xFF080D19),
    panel = Color(0xFF111B2D),
    elevated = Color(0xFF18263B),
    line = Color(0xFF29384D),
    cyan = Color(0xFF53DDD0),
    muted = Color(0xFF91A2BD),
    purple = Color(0xFFA59BFF),
    amber = Color(0xFFFFC87C),
    red = Color(0xFFFF8495);

class FutureMirrorApp extends StatelessWidget {
  const FutureMirrorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'FutureMirror • Decision Laboratory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(
              seedColor: cyan, brightness: Brightness.dark, surface: bg),
          fontFamily: 'Segoe UI',
          dividerColor: line,
          sliderTheme: SliderThemeData(
              activeTrackColor: cyan,
              inactiveTrackColor: line,
              thumbColor: cyan,
              overlayColor: cyan.withValues(alpha: .12))),
      home: const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var page = 0, busy = false;
  Scenario scenario = Scenario();
  final scenarioNameController =
      TextEditingController(text: 'Operational Stress Test');
  SimulationResult? result, comparison;
  List<SavedRun> history = [];
  String? selectedNode;
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    scenarioNameController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final loaded = await LocalStore.load();
    if (!mounted) return;
    setState(() => history = loaded);
    await _simulate(save: false);
  }

  Future<void> _simulate({bool save = true}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final computed = await Simulator.run(scenario.copy());
      if (save) {
        history.insert(0, SavedRun(DateTime.now(), scenario.copy(), computed));
        if (history.length > 80) history = history.take(80).toList();
        await LocalStore.save(history);
      }
      if (mounted) setState(() => result = computed);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Simulation failed: $error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _deleteRun(int index) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Delete saved run?'),
                content: Text(
                    'This permanently removes "${history[index].scenario.name}" from local history.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'))
                ]));
    if (confirmed != true || !mounted) return;
    setState(() => history.removeAt(index));
    await LocalStore.save(history);
  }

  void update(void Function() fn) {
    setState(fn);
  }

  String money(num x) =>
      '\$${x.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 1180;
      return Scaffold(
          body: Row(children: [
        Container(
            width: compact ? 74 : 230,
            decoration: const BoxDecoration(
                color: panel, border: Border(right: BorderSide(color: line))),
            child: Column(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(compact ? 16 : 22, 28, 12, 34),
                  child: Row(children: [
                    Icon(Icons.auto_awesome_mosaic, color: cyan, size: 28),
                    if (!compact) ...[
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Text('FUTUREMIRROR',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 1.3)))
                    ]
                  ])),
              ...[
                (Icons.space_dashboard_outlined, 'Command center'),
                (Icons.tune, 'Scenario lab'),
                (Icons.hub_outlined, 'Reality map'),
                (Icons.compare_arrows, 'Compare'),
                (Icons.history, 'Run history'),
                (Icons.verified_user_outlined, 'Evidence & model')
              ]
                  .asMap()
                  .entries
                  .map((e) => _nav(e.key, e.value.$1, e.value.$2, compact)),
              const Spacer(),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    Icon(Icons.lock_outline,
                        color: cyan.withValues(alpha: .8), size: 19),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      const Text('PRIVATE • LOCAL FIRST',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10, letterSpacing: 1, color: muted))
                    ],
                    const SizedBox(height: 14)
                  ]))
            ])),
        Expanded(
            child: Column(children: [
          Container(
              height: 74,
              padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 30),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: line))),
              child: Row(children: [
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          [
                            'Command center',
                            'Scenario laboratory',
                            'Reality map',
                            'Scenario comparison',
                            'Execution history',
                            'Evidence & limitations'
                          ][page],
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('Explore possible consequences before acting',
                          style: TextStyle(
                              color: muted, fontSize: compact ? 11 : 12))
                    ])),
                if (!compact)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 12),
                      decoration: BoxDecoration(
                          color: cyan.withValues(alpha: .09),
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: cyan.withValues(alpha: .25))),
                      child: const Row(children: [
                        Icon(Icons.circle, size: 7, color: cyan),
                        SizedBox(width: 8),
                        Text('LOCAL SIMULATION',
                            style: TextStyle(
                                fontSize: 10, color: cyan, letterSpacing: .8))
                      ])),
                const SizedBox(width: 18),
                IconButton(
                    tooltip: 'Run current scenario',
                    onPressed: busy ? null : () => _simulate(),
                    icon: busy
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.play_circle_outline, color: cyan))
              ])),
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(compact ? 18 : 30),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1430),
                      child: _page(compact))))
        ]))
      ]));
    });
  }

  Widget _nav(int index, IconData icon, String title, bool compact) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
          color:
              page == index ? cyan.withValues(alpha: .12) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => setState(() => page = index),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 13, vertical: 14),
                  child: Row(children: [
                    Icon(icon, color: page == index ? cyan : muted, size: 21),
                    if (!compact) ...[
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(title,
                              style: TextStyle(
                                  color: page == index ? Colors.white : muted,
                                  fontSize: 13,
                                  fontWeight: page == index
                                      ? FontWeight.w700
                                      : FontWeight.w400)))
                    ]
                  ])))));
  Widget _page(bool compact) => switch (page) {
        0 => _dashboard(compact),
        1 => _lab(compact),
        2 => _mapPage(compact),
        3 => _compare(compact),
        4 => _history(),
        _ => _evidence()
      };
  Widget _section(String title, String detail, {Widget? action}) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(detail, style: const TextStyle(color: muted, fontSize: 12))
        ])),
        if (action != null) action
      ]));
  Widget _card(Widget child, {EdgeInsets padding = const EdgeInsets.all(20)}) =>
      Container(
          padding: padding,
          decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: line)),
          child: child);
  Widget _metric(String label, String value, String note, IconData icon,
          Color color) =>
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: muted, fontSize: 12)),
          Icon(icon, color: color, size: 20)
        ]),
        const SizedBox(height: 18),
        Text(value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(note, style: const TextStyle(color: muted, fontSize: 11))
      ]));
  Widget _metrics(bool compact) {
    final r = result;
    return LayoutBuilder(
        builder: (context, constraints) => GridView.count(
                crossAxisCount: constraints.maxWidth < 620
                    ? 1
                    : constraints.maxWidth < 1120
                        ? 2
                        : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 145,
                children: [
                  _metric(
                      'Modeled cost impact',
                      r == null ? '—' : money(r.totalExtraCost),
                      'Illustrative USD exposure',
                      Icons.payments_outlined,
                      cyan),
                  _metric(
                      'Average risk',
                      r == null
                          ? '—'
                          : '${(r.avgProjectedRisk * 100).toStringAsFixed(0)}%',
                      'Modeled probability proxy',
                      Icons.shield_outlined,
                      amber),
                  _metric(
                      'Potential delay',
                      r == null ? '—' : '${r.maxDelayDays.toStringAsFixed(1)}d',
                      'Maximum node delay',
                      Icons.schedule,
                      red),
                  _metric(
                      'Systems affected',
                      r == null ? '—' : '${r.affectedCount} / ${nodes.length}',
                      'Impact score ≥ 12%',
                      Icons.hub_outlined,
                      purple)
                ]));
  }

  Widget _dashboard(bool compact) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _hero(compact),
        const SizedBox(height: 22),
        _metrics(compact),
        const SizedBox(height: 26),
        _section('Operational exposure',
            'The most impacted business systems for the current scenario',
            action: TextButton(
                onPressed: () => setState(() => page = 1),
                child: const Text('Adjust scenario  →'))),
        if (result != null)
          _card(Column(
              children:
                  result!.impacts.take(6).map((i) => _impactRow(i)).toList())),
        const SizedBox(height: 24),
        _card(const Row(children: [
          Icon(Icons.info_outline, color: amber),
          SizedBox(width: 12),
          Expanded(
              child: Text(
                  'Demonstration model: figures are hypothetical and must not be treated as validated predictions. Enter calibrated data before real-world decisions.',
                  style: TextStyle(color: muted, fontSize: 12)))
        ]))
      ]);
  Widget _hero(bool compact) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: const LinearGradient(
              colors: [Color(0xFF193B4C), Color(0xFF182540), Color(0xFF201F3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          border: Border.all(color: cyan.withValues(alpha: .15))),
      child: Wrap(
          runSpacing: 18,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
                width: compact ? 440 : 550,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DECISION INTELLIGENCE WORKSPACE',
                          style: TextStyle(
                              letterSpacing: 1.7,
                              fontSize: 10,
                              color: cyan,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 13),
                      const Text('See the ripple effects.\nBefore they happen.',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.2)),
                      const SizedBox(height: 12),
                      const Text(
                          'Test disruptions, trace dependencies and compare modeled outcomes in a private local environment.',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFBCC9DB),
                              height: 1.6)),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: cyan,
                              foregroundColor: bg,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 15)),
                          onPressed: () => setState(() => page = 1),
                          icon: const Icon(Icons.science_outlined),
                          label: const Text('Open Scenario Lab'))
                    ])),
            Icon(Icons.scatter_plot_outlined,
                size: compact ? 50 : 100, color: cyan.withValues(alpha: .6))
          ]));
  Widget _impactRow(NodeImpact i) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: _riskColor(i.score), shape: BoxShape.circle)),
        const SizedBox(width: 12),
        SizedBox(
            width: 125,
            child: Text(i.label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                    value: i.score,
                    minHeight: 8,
                    color: _riskColor(i.score),
                    backgroundColor: elevated))),
        const SizedBox(width: 15),
        SizedBox(
            width: 48,
            child: Text('${(i.score * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700))),
        const SizedBox(width: 16),
        SizedBox(
            width: 82,
            child: Text(money(i.extraCost),
                textAlign: TextAlign.right,
                style: const TextStyle(color: muted, fontSize: 12)))
      ]));
  Color _riskColor(double x) => x >= .50
      ? red
      : x >= .30
          ? amber
          : cyan;
  Widget _lab(bool compact) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('Build a hypothetical scenario',
            'Adjust shocks to test how a disruption could travel through the operational network'),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SCENARIO NAME',
              style: TextStyle(color: muted, letterSpacing: 1.2, fontSize: 10)),
          const SizedBox(height: 9),
          TextFormField(
              controller: scenarioNameController,
              onChanged: (v) => scenario.name = v,
              decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: elevated,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          _slider(
              'Workforce unavailable',
              scenario.staffAbsence,
              Icons.groups_2_outlined,
              (v) => update(() => scenario.staffAbsence = v)),
          _slider(
              'Supplier disruption',
              scenario.supplierDelay,
              Icons.local_shipping_outlined,
              (v) => update(() => scenario.supplierDelay = v)),
          _slider('Demand increase', scenario.demandSpike, Icons.trending_up,
              (v) => update(() => scenario.demandSpike = v)),
          _slider('Technology outage', scenario.itOutage, Icons.dns_outlined,
              (v) => update(() => scenario.itOutage = v)),
          _slider(
              'Cash-flow pressure',
              scenario.cashPressure,
              Icons.account_balance_wallet_outlined,
              (v) => update(() => scenario.cashPressure = v)),
          const Divider(height: 32),
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Simulation horizon',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ...([7, 30, 90].map((d) => ChoiceChip(
                    label: Text('$d days'),
                    selected: scenario.horizonDays == d,
                    onSelected: (_) => update(() => scenario.horizonDays = d))))
              ]),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cyan, foregroundColor: bg),
                onPressed: busy ? null : () => _simulate(),
                icon: const Icon(Icons.play_arrow),
                label: Text(busy ? 'Running...' : 'Run & save simulation')),
            OutlinedButton.icon(
                onPressed: () {
                  final baseline = Scenario(
                      staffAbsence: 0,
                      supplierDelay: 0,
                      demandSpike: 0,
                      itOutage: 0,
                      cashPressure: 0);
                  scenarioNameController.text = baseline.name;
                  update(() => scenario = baseline);
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to baseline')),
            OutlinedButton.icon(
                onPressed: result == null
                    ? null
                    : () => setState(() {
                          comparison = result;
                          page = 3;
                        }),
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Pin for comparison'))
          ])
        ])),
        const SizedBox(height: 22),
        _metrics(compact),
        const SizedBox(height: 24),
        _section('Modeled outcomes',
            'Results refresh after clicking Run & save simulation'),
        if (result != null)
          _card(Column(children: result!.impacts.map(_impactRow).toList()))
      ]);
  Widget _slider(String label, double value, IconData icon,
          ValueChanged<double> onChange) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            Icon(icon, size: 19, color: muted),
            const SizedBox(width: 11),
            SizedBox(
                width: 160,
                child: Text(label, style: const TextStyle(fontSize: 12))),
            Expanded(child: Slider(value: value, onChanged: onChange)),
            SizedBox(
                width: 48,
                child: Text('${(value * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)))
          ]));
  Widget _mapPage(bool compact) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('Reality map',
            'Dependency arrows show which systems can transmit operational pressure'),
        _card(Column(children: [
          SizedBox(
              height: compact ? 380 : 500,
              child: LayoutBuilder(
                  builder: (ctx, c) => GestureDetector(
                      onTapDown: (e) {
                        final x = e.localPosition.dx / c.maxWidth,
                            y = e.localPosition.dy / c.maxHeight;
                        MirrorNode? closest;
                        double dist = 999;
                        for (final n in nodes) {
                          final d = pow((n.x - x) * c.maxWidth, 2) +
                              pow((n.y - y) * c.maxHeight, 2);
                          if (d < dist) {
                            dist = d.toDouble();
                            closest = n;
                          }
                        }
                        if (dist < 3200) {
                          setState(() => selectedNode = closest?.id);
                        }
                      },
                      child: CustomPaint(
                          painter: GraphPainter(result, selectedNode),
                          child: const SizedBox.expand())))),
          const SizedBox(height: 8),
          const Text(
              'Click a node to inspect it. Connections represent example dependencies, not verified operational relationships.',
              style: TextStyle(color: muted, fontSize: 11))
        ])),
        const SizedBox(height: 16),
        if (selectedNode != null && result != null) ...[
          Builder(builder: (context) {
            final i = result!.impacts.firstWhere((e) => e.id == selectedNode);
            return _card(
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(i.label,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  'Category: ${i.category}     Impact: ${(i.score * 100).toStringAsFixed(0)}%     Projected risk: ${(i.projectedRisk * 100).round()}%',
                  style: const TextStyle(color: muted)),
              const SizedBox(height: 10),
              ...i.reasons.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text('• $s')))
            ]));
          })
        ]
      ]);
  Widget _compare(bool compact) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('Compare scenarios',
            'Pin a result, run an alternative, then inspect differences'),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('COMPARISON REFERENCE',
              style: TextStyle(fontSize: 11, color: muted, letterSpacing: 1.1)),
          const SizedBox(height: 9),
          if (history.isNotEmpty)
            DropdownButton<int>(
                isExpanded: true,
                value: null,
                hint: Text(comparison == null
                    ? 'Select a saved run'
                    : 'Pinned: ${money(comparison!.totalExtraCost)} cost exposure'),
                items: history
                    .asMap()
                    .entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                            '${e.value.scenario.name}  •  ${e.value.timestamp.toLocal().toString().substring(0, 16)}')))
                    .toList(),
                onChanged: (i) =>
                    setState(() => comparison = history[i!].result))
          else
            const Text('Run and save a scenario first.'),
          const SizedBox(height: 15),
          if (comparison != null && result != null) ...[
            const Divider(),
            const SizedBox(height: 12),
            _compareLine(
                'Cost exposure',
                money(comparison!.totalExtraCost),
                money(result!.totalExtraCost),
                result!.totalExtraCost - comparison!.totalExtraCost),
            _compareLine(
                'Average risk',
                '${(comparison!.avgProjectedRisk * 100).round()}%',
                '${(result!.avgProjectedRisk * 100).round()}%',
                (result!.avgProjectedRisk - comparison!.avgProjectedRisk) *
                    100),
            _compareLine(
                'Delay exposure',
                '${comparison!.maxDelayDays} days',
                '${result!.maxDelayDays} days',
                result!.maxDelayDays - comparison!.maxDelayDays),
            const SizedBox(height: 12),
            const Text(
                'A positive change means greater modeled exposure, not a measured outcome.',
                style: TextStyle(color: muted, fontSize: 11))
          ]
        ])),
        const SizedBox(height: 22),
        if (comparison != null && result != null)
          _card(Column(
              children: result!.impacts.map((i) {
            final before = comparison!.impacts.firstWhere((n) => n.id == i.id);
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(children: [
                  SizedBox(width: 140, child: Text(i.label)),
                  Expanded(
                      child: LinearProgressIndicator(
                          value: before.score,
                          minHeight: 7,
                          color: purple,
                          backgroundColor: elevated)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: LinearProgressIndicator(
                          value: i.score,
                          minHeight: 7,
                          color: cyan,
                          backgroundColor: elevated))
                ]));
          }).toList()))
      ]);
  Widget _compareLine(String label, String left, String right, double delta) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(children: [
            Expanded(flex: 2, child: Text(label)),
            Expanded(
                child: Text(left,
                    style: const TextStyle(
                        color: purple, fontWeight: FontWeight.w700))),
            const Icon(Icons.arrow_forward, color: muted, size: 15),
            const SizedBox(width: 10),
            Expanded(
                child: Text(right,
                    style: const TextStyle(
                        color: cyan, fontWeight: FontWeight.w700))),
            Icon(
                delta > 0
                    ? Icons.trending_up
                    : delta < 0
                        ? Icons.trending_down
                        : Icons.remove,
                color: delta > 0 ? red : cyan)
          ]));
  Widget _history() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section(
            'Saved runs', 'Simulation history stored only on this computer'),
        if (history.isEmpty)
          _card(const Text(
              'No saved runs yet. Open Scenario Lab and run your first simulation.'))
        else
          _card(Column(
              children: history.asMap().entries.map((entry) {
            final h = entry.value;
            return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                leading: const Icon(Icons.analytics_outlined, color: cyan),
                title: Text(h.scenario.name),
                subtitle: Text(
                    '${h.timestamp.toLocal().toString().substring(0, 19)}  •  ${h.result.engine}',
                    style: const TextStyle(color: muted, fontSize: 11)),
                trailing: Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(money(h.result.totalExtraCost),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(
                          tooltip: 'Load scenario',
                          onPressed: () => setState(() {
                                scenario = h.scenario.copy();
                                scenarioNameController.text = scenario.name;
                                result = h.result;
                                page = 1;
                              }),
                          icon: const Icon(Icons.open_in_new, size: 18)),
                      IconButton(
                          tooltip: 'Delete run',
                          onPressed: () => _deleteRun(entry.key),
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: red))
                    ]));
          }).toList()))
      ]);
  Widget _evidence() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('Model transparency',
            'What the simulator knows, assumes, and does not know'),
        _card(const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MODEL STATUS',
                  style:
                      TextStyle(color: cyan, letterSpacing: 1.3, fontSize: 10)),
              SizedBox(height: 13),
              Text('Illustrative / uncalibrated',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                  'FutureMirror currently uses eight fictional example systems, eleven directed dependencies, invented baseline USD costs, illustrative risk baselines and hand-authored sensitivity coefficients. The output is not validated against real organizations.',
                  style: TextStyle(color: muted, height: 1.7)),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 12),
              Text('What is calculated',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 9),
              Text(
                  '1. Direct node shocks from five scenario controls.\n2. Five rounds of weighted dependency propagation.\n3. Illustrative added cost, risk index and delay indicators.\n4. Ranked impacts and potential contributing factors.',
                  style: TextStyle(height: 1.9)),
              SizedBox(height: 20),
              Text('Important limitations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 9),
              Text(
                  '• No live company data or predictive machine learning.\n• No probabilities, confidence intervals or empirical calibration.\n• Dependencies are predefined demonstration data.\n• Scenario values are fractional stress intensities, not measured forecasts.\n• Output must not guide financial, safety or operational decisions without verification.',
                  style: TextStyle(color: muted, height: 1.9))
            ])),
        const SizedBox(height: 16),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Execution engine',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(result?.engine ?? 'Not started',
              style: const TextStyle(color: cyan)),
          const SizedBox(height: 9),
          const Text(
              'If the compiled Rust executable is present in engine/target/release, the application uses Rust. Otherwise, the corresponding Dart calculation runs locally.',
              style: TextStyle(color: muted, height: 1.6))
        ]))
      ]);
}

class GraphPainter extends CustomPainter {
  final SimulationResult? result;
  final String? selected;
  GraphPainter(this.result, this.selected);
  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in nodes) n.id: n};
    final scores = {
      for (final i in result?.impacts ?? <NodeImpact>[]) i.id: i.score
    };
    final gridPaint = Paint()
      ..color = const Color(0xFF253348)
      ..strokeWidth = .6;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (final e in edges) {
      final a = nodeMap[e.from]!, b = nodeMap[e.to]!;
      final start = Offset(a.x * size.width, a.y * size.height),
          end = Offset(b.x * size.width, b.y * size.height);
      final direction = end - start;
      final norm = direction.distance == 0 ? 1.0 : direction.distance;
      final unit = direction / norm;
      final p1 = start + unit * 25, p2 = end - unit * 28;
      final paint = Paint()
        ..color = cyan.withValues(alpha: .16 + .22 * e.strength)
        ..strokeWidth = 1.2 + e.strength;
      canvas.drawLine(p1, p2, paint);
      final left = Offset(-unit.dy, unit.dx);
      final path = Path()
        ..moveTo(p2.dx, p2.dy)
        ..lineTo((p2 - unit * 9 + left * 4).dx, (p2 - unit * 9 + left * 4).dy)
        ..lineTo((p2 - unit * 9 - left * 4).dx, (p2 - unit * 9 - left * 4).dy)
        ..close();
      canvas.drawPath(path, Paint()..color = cyan.withValues(alpha: .4));
    }
    for (final n in nodes) {
      final o = Offset(n.x * size.width, n.y * size.height),
          score = scores[n.id] ?? 0;
      final color = score >= .50
          ? red
          : score >= .30
              ? amber
              : cyan;
      canvas.drawCircle(o, selected == n.id ? 33 : 27,
          Paint()..color = color.withValues(alpha: .08));
      canvas.drawCircle(o, 22, Paint()..color = elevated);
      canvas.drawCircle(
          o,
          22,
          Paint()
            ..color = color.withValues(alpha: .9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = selected == n.id ? 3 : 1.6);
      canvas.drawCircle(o, 5 + score * 8, Paint()..color = color);
      final tp = TextPainter(
          text: TextSpan(
              text: n.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy + 29));
      final t = TextPainter(
          text: TextSpan(
              text: '${(score * 100).round()}% impact',
              style: const TextStyle(color: muted, fontSize: 10)),
          textDirection: TextDirection.ltr)
        ..layout();
      t.paint(canvas, Offset(o.dx - t.width / 2, o.dy + 45));
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter old) =>
      old.result != result || old.selected != selected;
}
