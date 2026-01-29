// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/goals/goals.page.dart';
import 'package:sentimento_app/ui/pages/home/home.page.dart';
import 'package:sentimento_app/ui/pages/journal/journal.page.dart';
import 'package:sentimento_app/ui/pages/profile/profile.page.dart';

import 'package:sentimento_app/ui/pages/stats/stats.page.dart';
import 'package:sentimento_app/ui/pages/gym/gym_list_page.dart';
import 'package:sentimento_app/ui/shared/widgets/app_drawer.dart';
import 'package:sentimento_app/ui/shared/widgets/custom_bottom_nav.dart';

/// MainPage - Página principal com navegação inferior e drawer
class MainPageWidget extends StatefulWidget {
  const MainPageWidget({super.key});

  static const String routeName = 'Main';
  static const String routePath = '/main';

  @override
  State<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = const [
    HomePageWidget(),
    JournalPageWidget(),
    GymListPage(),
    GoalsPageWidget(),
    StatsPageWidget(),
    ProfilePageWidget(),
  ];

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.primaryBackground,
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) => setState(() => _currentIndex = index),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() => _currentIndex = index);
        },
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }
}
