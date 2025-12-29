import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/main.dart';
import 'profile.model.dart';

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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primary.withOpacity(0.2),
                          theme.secondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [theme.primary, theme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (model.userName?.isNotEmpty ?? false)
                                  ? model.userName![0].toUpperCase()
                                  : 'U',
                              style: theme.displaySmall.override(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          model.userName ?? 'Usuário',
                          style: theme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.userEmail ?? '',
                          style: theme.labelMedium.override(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings section
                  _SectionTitle(title: 'Configurações', theme: theme),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Modo Escuro',
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        MyApp.of(context).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeColor: theme.primary,
                    ),
                  ),

                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notificações',
                    trailing: Switch.adaptive(
                      value: model.notificationsEnabled,
                      onChanged: (value) => model.notificationsEnabled = value,
                      activeColor: theme.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data section
                  _SectionTitle(title: 'Dados', theme: theme),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Exportar Dados',
                    subtitle: 'Baixe seus registros de humor',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Exportação em breve!'),
                          backgroundColor: theme.primary,
                        ),
                      );
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Estatísticas Avançadas',
                    subtitle: 'Veja análises detalhadas',
                    onTap: () {
                      context.pushNamed('Stats');
                    },
                  ),

                  const SizedBox(height: 24),

                  // About section
                  _SectionTitle(title: 'Sobre', theme: theme),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Versão do App',
                    subtitle: '1.0.0',
                  ),

                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de Privacidade',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await model.signOut(context);
                        if (context.mounted) {
                          context.goNamed('Login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sair'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.error,
                        side: BorderSide(color: theme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final FlutterFlowTheme theme;

  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.titleSmall.override(color: theme.secondaryText),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.primary, size: 20),
        ),
        title: Text(title, style: theme.bodyMedium),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.labelSmall.override(color: theme.secondaryText),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded, color: theme.secondaryText)
                : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
