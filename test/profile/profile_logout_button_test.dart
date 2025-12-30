import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentimento_app/ui/pages/profile/widgets/profile_logout_button.dart';

void main() {
  testWidgets(
    'ProfileLogoutButton should render correctly and trigger onPressed',
    (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileLogoutButton(
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      // Check if button text is present
      expect(find.text('Sair'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      // Verify onPressed was called
      expect(pressed, isTrue);
    },
  );
}
