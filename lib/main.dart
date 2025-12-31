// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  // Load environment variables first
  try {
    await dotenv.load(fileName: '.env');
    logger.i('dotenv carregado com sucesso!');
  } catch (e) {
    logger.e('Erro ao carregar dotenv: $e');
  }

  try {
    await SupaFlow.initialize();
    logger.i('Supabase initialize com sucesso!');
  } catch (e) {
    logger.e('Erro ao iniciar Supabase: $e');
  }

  // Initialize Firebase and Notifications
  try {
    await NotificationService().initialize();
    logger.i('NotificationService inicializado com sucesso!');
  } catch (e) {
    logger.e('Erro ao iniciar NotificationService: $e');
  }

  await FlutterFlowTheme.initialize();

  final appState = AppStateNotifier.instance;

  // Restore session before app starts
  final authUser = SupaFlow.client.auth.currentUser;
  if (authUser != null) {
    currentUser = SentimentoAppSupabaseUser(authUser);
    appState.update(currentUser!);
  }

  await appState.initializePersistedState();

  runApp(
    ChangeNotifierProvider(create: (context) => appState, child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late Stream<BaseAuthUser> userStream;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = sentimentoAppSupabaseUserStream()
      ..listen((user) => _appStateNotifier.update(user));
    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(seconds: 1),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    // Check first run for permissions
    _checkFirstRunPermissions();
  }

  /// Check if this is first run and show permission dialog
  Future<void> _checkFirstRunPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPermissions = prefs.getBool('has_seen_permissions') ?? false;

    if (!hasSeenPermissions && mounted) {
      // Wait for navigation to complete
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  /// Show first-run permission dialog
  void _showPermissionDialog() {
    final theme = FlutterFlowTheme.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.notifications_active, color: theme.primary),
            ),
            const SizedBox(width: 12),
            const Text('Permissões'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para uma melhor experiência, precisamos de algumas permissões:',
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _PermissionItem(
              icon: Icons.notifications_rounded,
              title: 'Notificações',
              description: 'Lembretes diários sobre humor e metas',
            ),
            const SizedBox(height: 12),
            _PermissionItem(
              icon: Icons.schedule_rounded,
              title: 'Alarmes',
              description: 'Agendamento de lembretes',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_seen_permissions', true);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Depois', style: TextStyle(color: theme.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_seen_permissions', true);
              if (context.mounted) Navigator.pop(context);
              // Permissions are already requested by NotificationService.initialize()
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Permitir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    FlutterFlowTheme.saveThemeMode(mode);
  });

  String getRoute() => _router.getCurrentLocation();
  List<String> getRouteStack() => [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sentimento App',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

/// Permission item widget for the first-run dialog
class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.bodyMedium.override(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: theme.labelSmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
