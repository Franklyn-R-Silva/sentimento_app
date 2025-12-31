// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sentimento_app/ui/pages/profile/widgets/profile_section_title.dart';

void main() {
  testWidgets('ProfileSectionTitle should render the title text', (
    WidgetTester tester,
  ) async {
    const testTitle = 'Configurações de Teste';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileSectionTitle(title: testTitle)),
      ),
    );

    expect(find.text(testTitle), findsOneWidget);
  });
}
