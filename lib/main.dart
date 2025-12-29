import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/core/nav/nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupaFlow.initialize();

  await FlutterFlowTheme.initialize();

  final appState = AppStateNotifier.instance;
  appState.initializePersistedState();

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
