// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/auth/base_auth_user_provider.dart';
import 'package:sentimento_app/main.dart';
import 'package:sentimento_app/ui/pages/profile/profile.page.dart';
import '../mocks/mocks.dart';

// Mock for MyAppState to handle setThemeMode
class MockMyAppState extends Fake implements MyAppState {
  @override
  void setThemeMode(ThemeMode mode) {}

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'MockMyAppState';
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockBaseAuthUser mockAuthUser;

  setUpAll(() {
    registerFallbackValue(ThemeMode.light);
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockAuthUser = MockBaseAuthUser();
    final mockGoTrue = MockGoTrueClient();
    final mockUser = MockUser();

    // Mock currentUser globals
    currentUser = mockAuthUser;
    when(() => mockAuthUser.loggedIn).thenReturn(true);
    when(() => mockAuthUser.uid).thenReturn('test-uid');
    when(() => mockAuthUser.email).thenReturn('franklyn@example.com');
    when(() => mockAuthUser.displayName).thenReturn('Franklyn Silva');
    when(() => mockAuthUser.photoUrl).thenReturn(null);

    // Mock Supabase Auth
    when(() => mockSupabase.auth).thenReturn(mockGoTrue);
    when(() => mockGoTrue.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-uid');
    when(() => mockUser.email).thenReturn('franklyn@example.com');
    when(() => mockUser.userMetadata).thenReturn({'name': 'Franklyn Silva'});

    // Mock Supabase Database
    when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer(
      (_) => FakePostgrestFilterBuilderList(
        [],
        singleResult: {'avatar_url': 'example.com'},
      ),
    );
  });

  testWidgets('ProfilePage should render all sections and widgets', (
    WidgetTester tester,
  ) async {
    // Create a real model with mocked dependencies
    final model = ProfileModel(supabaseClient: mockSupabase);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<ProfileModel>.value(value: model)],
        child: const MaterialApp(home: ProfilePageWidget()),
      ),
    );

    // We need to pump again because loadUserData is async in initState
    await tester.pump();

    // Check Header
    expect(find.text('Franklyn Silva'), findsOneWidget);
    expect(find.text('franklyn@example.com'), findsOneWidget);

    // Check Sections
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Dados'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);

    // Check specific tiles
    expect(find.text('Modo Escuro'), findsOneWidget);
    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Exportar Dados'), findsOneWidget);
    expect(find.text('Alterar Senha'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
  });
}
