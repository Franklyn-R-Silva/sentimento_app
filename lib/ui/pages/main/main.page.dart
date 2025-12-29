import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/home/home.page.dart';
import 'package:sentimento_app/ui/pages/journal/journal.page.dart';
import 'package:sentimento_app/ui/pages/profile/profile.page.dart';
import 'package:sentimento_app/ui/pages/stats/stats.page.dart';
import 'package:sentimento_app/ui/shared/widgets/custom_bottom_nav.dart';

/// MainPage - Página principal com navegação inferior
class MainPageWidget extends StatefulWidget {
  const MainPageWidget({super.key});

  static const String routeName = 'Main';
  static const String routePath = '/main';

  @override
  State<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePageWidget(),
    JournalPageWidget(),
    StatsPageWidget(),
    ProfilePageWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
