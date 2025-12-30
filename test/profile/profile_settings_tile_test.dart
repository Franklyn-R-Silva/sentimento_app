import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentimento_app/ui/pages/profile/widgets/profile_settings_tile.dart';

void main() {
  testWidgets(
    'ProfileSettingsTile should render icon, title, subtitle and trigger onTap',
    (WidgetTester tester) async {
      bool tapped = false;
      const testTitle = 'Título de Configuração';
      const testSubtitle = 'Subtítulo detalhado';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsTile(
              icon: Icons.settings,
              title: testTitle,
              subtitle: testSubtitle,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapped, isTrue);
    },
  );

  testWidgets('ProfileSettingsTile should render custom trailing widget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSettingsTile(
            icon: Icons.notifications,
            title: 'Notificações',
            trailing: Switch(value: true, onChanged: null),
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });
}
