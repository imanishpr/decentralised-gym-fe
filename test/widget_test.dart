import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_visit_flutter/app.dart';

void main() {
  testWidgets('app bootstraps', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymVisitApp()));
    expect(find.byType(GymVisitApp), findsOneWidget);
  });
}
