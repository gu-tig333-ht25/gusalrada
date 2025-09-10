import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_ui/main.dart';

void main() {
  testWidgets('App renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    expect(find.text('TIG333 TODO'), findsOneWidget);
  });
}
