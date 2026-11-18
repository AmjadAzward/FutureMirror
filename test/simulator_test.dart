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
}
