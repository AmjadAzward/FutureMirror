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
    expect(find.text('Modeled cost impact'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
