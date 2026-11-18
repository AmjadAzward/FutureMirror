import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:future_mirror/main.dart';

void main() {
  testWidgets(
      'dashboard renders without layout errors at a medium desktop size',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FutureMirrorApp());
    await tester.pumpAndSettle();

    expect(find.text('Command center'), findsOneWidget);
    expect(find.text('START HERE'), findsOneWidget);
    expect(find.text('Open Scenario Lab'), findsWidgets);
    expect(find.text('Modeled cost impact'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('model editor opens and renders the persisted graph',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FutureMirrorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Model editor'));
    await tester.pumpAndSettle();

    expect(find.text('Operational model'), findsWidgets);
    expect(find.text('Systems'), findsOneWidget);
    expect(find.text('Dependencies'), findsOneWidget);
    expect(find.textContaining('feedback loop'), findsOneWidget);
    expect(find.textContaining('disconnected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workspace portability controls are available in run history',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FutureMirrorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run history'));
    await tester.pumpAndSettle();

    expect(find.text('Copy workspace backup'), findsOneWidget);
    expect(find.text('Restore workspace'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
