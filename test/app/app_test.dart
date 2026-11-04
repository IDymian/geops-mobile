import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/app.dart';

void main() {
  testWidgets('app starts on the welcome page', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GeopsApp()));
    await tester.pumpAndSettle();

    expect(find.text('GeoPS'), findsOneWidget);
  });
}
