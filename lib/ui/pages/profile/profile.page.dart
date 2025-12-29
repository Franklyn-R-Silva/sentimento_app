import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/main.dart';
import 'profile.model.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_settings_tile.dart';
import 'widgets/profile_section_title.dart';
import 'widgets/profile_logout_button.dart';

export 'profile.model.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  static const String routeName = 'Profile';
  static const String routePath = '/profile';

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  late ProfileModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
    _model.loadUserData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileModel>.value(
      value: _model,
      child: Consumer<ProfileModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Perfil',
                style: theme.headlineMedium.override(color: theme.primaryText),
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  ProfileHeader(
                    userName: model.userName,
                    userEmail: model.userEmail,
                  ),

                  const SizedBox(height: 24),

                  // Settings section
                  const ProfileSectionTitle(title: 'Configurações'),
                  const SizedBox(height: 12),

                  ProfileSettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Modo Escuro',
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        MyApp.of(context).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeTrackColor: theme.primary,
                    ),
                  ),

                  ProfileSettingsTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notificações',
                    trailing: Switch.adaptive(
                      value: model.notificationsEnabled,
                      onChanged: (value) => model.notificationsEnabled = value,
                      activeTrackColor: theme.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data section
                  const ProfileSectionTitle(title: 'Dados'),
                  const SizedBox(height: 12),

                  ProfileSettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Exportar Dados',
                    subtitle: 'Baixe seus registros de humor',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Exportação em breve!'),
                          backgroundColor: theme.primary,
                        ),
                      );
                    },
                  ),

                  ProfileSettingsTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Estatísticas Avançadas',
                    subtitle: 'Veja análises detalhadas',
                    onTap: () {
                      context.pushNamed('Stats');
                    },
                  ),

                  const SizedBox(height: 24),

                  // About section
                  const ProfileSectionTitle(title: 'Sobre'),
                  const SizedBox(height: 12),

                  const ProfileSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Versão do App',
                    subtitle: '1.0.0',
                  ),

                  ProfileSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de Privacidade',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // Logout button
                  ProfileLogoutButton(
                    onPressed: () async {
                      await model.signOut(context);
                      if (context.mounted) {
                        context.goNamed('Login');
                      }
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
