
import 'package:flutter_test/flutter_test.dart';
import 'package:studyai/main.dart';

void main() {
  testWidgets('StudyAI muestra su pantalla de bienvenida',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudyAI());

    expect(find.text('StudyAI'), findsOneWidget);
    expect(find.text('Comenzar ahora'), findsOneWidget);
  });
}
