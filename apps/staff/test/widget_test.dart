import 'package:flutter_test/flutter_test.dart';

import 'package:al3b_staff/main.dart';

void main() {
  testWidgets('Floor screen shows the sample units', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('الصالة'), findsOneWidget); // title, in Arabic
    expect(find.text('PS5-1'), findsOneWidget);
    expect(find.text('بلياردو 2'), findsOneWidget);
  });
}
