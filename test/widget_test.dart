import 'package:flutter_test/flutter_test.dart';
import 'package:mmm_society_app/main.dart';

void main() {
  testWidgets('MMM Society app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MmmSocietyApp());

    expect(find.text('MMM Society'), findsWidgets);
    expect(find.text('Society Management System'), findsOneWidget);
    expect(find.text('Supabase connected'), findsOneWidget);
  });
}