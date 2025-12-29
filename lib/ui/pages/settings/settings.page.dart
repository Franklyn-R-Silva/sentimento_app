import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/main.dart';

/// SettingsPageWidget - Página de configurações dedicada
class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  static const String routeName = 'Settings';
  static const String routePath = '/settings';

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  bool _notificationsEnabled = true;
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurações',
          style: theme.headlineMedium.override(color: theme.primaryText),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aparência
            _SectionHeader(title: '🎨 Aparência', theme: theme),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.dark_mode_rounded,
                    iconColor: const Color(0xFF5E35B1),
                    title: 'Modo Escuro',
                    subtitle: 'Menos luz para seus olhos',
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        MyApp.of(context).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.alternate,
                    ),
                  ),
                  Divider(color: theme.alternate, height: 1),
                  _SettingRow(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFFFF9800),
                    title: 'Tema Automático',
                    subtitle: 'Seguir configuração do sistema',
                    trailing: TextButton(
                      onPressed: () {
                        MyApp.of(context).setThemeMode(ThemeMode.system);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Tema automático ativado'),
                            backgroundColor: theme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Ativar',
                        style: theme.labelMedium.override(color: theme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notificações
            _SectionHeader(title: '🔔 Notificações', theme: theme),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Notificações',
                    subtitle: 'Receber lembretes e dicas',
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.alternate,
                    ),
                  ),
                  Divider(color: theme.alternate, height: 1),
                  _SettingRow(
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xFF2196F3),
                    title: 'Lembrete Diário',
                    subtitle: 'Receber lembrete para registrar humor',
                    trailing: Switch.adaptive(
                      value: _dailyReminder,
                      onChanged: _notificationsEnabled
                          ? (value) => setState(() => _dailyReminder = value)
                          : null,
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.alternate,
                    ),
                  ),
                  if (_dailyReminder && _notificationsEnabled) ...[
                    Divider(color: theme.alternate, height: 1),
                    _SettingRow(
                      icon: Icons.schedule_rounded,
                      iconColor: const Color(0xFF9C27B0),
                      title: 'Horário do Lembrete',
                      subtitle: _reminderTime.format(context),
                      trailing: IconButton(
                        icon: Icon(Icons.edit_rounded, color: theme.primary),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime,
                          );
                          if (time != null) {
                            setState(() => _reminderTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bem-estar
            _SectionHeader(title: '💜 Bem-estar', theme: theme),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.spa_rounded,
                    iconColor: const Color(0xFF7C4DFF),
                    title: 'Mensagens de Apoio',
                    subtitle: 'Receber frases motivacionais',
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {},
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.alternate,
                    ),
                  ),
                  Divider(color: theme.alternate, height: 1),
                  _SettingRow(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFFE53935),
                    title: 'Linha de Apoio',
                    subtitle: 'CVV: 188 (24 horas)',
                    trailing: IconButton(
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        color: theme.primary,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'CVV - Centro de Valorização da Vida\nLigue 188 (24 horas)',
                            ),
                            backgroundColor: theme.primary,
                            duration: const Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Privacidade
            _SectionHeader(title: '🔒 Privacidade', theme: theme),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.download_rounded,
                    iconColor: const Color(0xFF009688),
                    title: 'Exportar Dados',
                    subtitle: 'Baixe todos seus registros',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Exportação em breve!'),
                          backgroundColor: theme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(color: theme.alternate, height: 1),
                  _SettingRow(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFE53935),
                    title: 'Apagar Dados',
                    subtitle: 'Remover todos os registros',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Apagar Dados'),
                          content: const Text(
                            'Tem certeza que deseja apagar todos os seus registros? Esta ação não pode ser desfeita.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Apagar',
                                style: TextStyle(color: theme.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final FlutterFlowTheme theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.titleMedium.override(fontWeight: FontWeight.w600),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.labelSmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }
}
