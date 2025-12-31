// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:app_settings/app_settings.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/main.dart';
import 'package:sentimento_app/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final schedules = NotificationService().schedules;

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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notificações
            _SectionHeader(
              title: 'Notificações',
              theme: theme,
              iconWidget: Image.asset(
                'assets/images/imagem_2.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Notificações',
                    subtitle: 'Ativar lembretes do aplicativo',
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        setState(() => _notificationsEnabled = value);
                        await NotificationService().setNotificationsEnabled(
                          value,
                        );
                      },
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.alternate,
                    ),
                  ),
                ],
              ),
            ),
// ...
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: schedules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return _SettingCard(
                      child: _SettingRow(
                        icon: Icons.alarm_rounded,
                        iconColor: theme.primary,
                        title: _formatTime(schedule.hour, schedule.minute),
                        subtitle: _formatDays(schedule.activeDays),
                        onTap: () => _openScheduleDialog(context, schedule),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch.adaptive(
                              value: schedule.isEnabled,
                              onChanged: (val) async {
                                final updated = NotificationSchedule(
                                  id: schedule.id,
                                  title: schedule.title,
                                  body: schedule.body,
                                  hour: schedule.hour,
                                  minute: schedule.minute,
                                  activeDays: schedule.activeDays,
                                  isEnabled: val,
                                );
                                await NotificationService().updateSchedule(
                                  updated,
                                );
                                _refresh();
                              },
                              activeTrackColor: theme.primary,
                              inactiveTrackColor: theme.alternate,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
// ...
  void _openScheduleDialog(
    BuildContext context, [
    NotificationSchedule? schedule,
  ]) {
    final theme = FlutterFlowTheme.of(context);

    TimeOfDay selectedTime = schedule != null
        ? TimeOfDay(hour: schedule.hour, minute: schedule.minute)
        : const TimeOfDay(hour: 8, minute: 0);

    final List<int> selectedDays = schedule != null
        ? List<int>.from(schedule.activeDays)
        : [1, 2, 3, 4, 5, 6, 7]; // Default all days

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                schedule == null ? 'Novo Lembrete' : 'Editar Lembrete',
                style: theme.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time Picker Button
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setDialogState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.primary),
                      ),
                      child: Text(
                        selectedTime.format(context),
                        style: theme.displaySmall.override(
                          color: theme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Dias da Semana:', style: theme.bodyMedium),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final dayIndex = index + 1; // 1 = Mon
                      // Custom labels: Mon(1)=S, Tue(2)=T, Wed(3)=Q, Thu(4)=Q, Fri(5)=S, Sat(6)=S, Sun(7)=D
                      final displayLabel = [
                        'S',
                        'T',
                        'Q',
                        'Q',
                        'S',
                        'S',
                        'D',
                      ][index];
                      final isSelected = selectedDays.contains(dayIndex);

                      return FilterChip(
                        label: Text(displayLabel),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedDays.add(dayIndex);
                            } else {
                              selectedDays.remove(dayIndex);
                            }
                          });
                        },
                        selectedColor: theme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: theme.primaryBackground,
                        side: BorderSide(
                          color: isSelected ? theme.primary : theme.alternate,
                        ),
                        shape: const CircleBorder(),
                        showCheckmark: false,
                        padding: const EdgeInsets.all(4),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                if (schedule != null)
                  TextButton(
                    onPressed: () async {
                      await NotificationService().deleteSchedule(schedule.id);
                      if (context.mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _refresh();
                    },
                    child: Text(
                      'Excluir',
                      style: TextStyle(color: theme.error),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: theme.secondaryText),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Selecione pelo menos um dia.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: theme.error,
                        ),
                      );
                      return;
                    }

                    final newSchedule = NotificationSchedule(
                      id:
                          schedule?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                      title: 'Lembrete do Sentimento',
                      body: 'Hora de registrar como você está se sentindo!',
                      activeDays: selectedDays..sort(),
                      isEnabled: true,
                    );

                    if (schedule == null) {
                      await NotificationService().addSchedule(newSchedule);
                    } else {
                      await NotificationService().updateSchedule(newSchedule);
                    }

                    if (context.mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    _refresh();
                  },
                  child: Text('Salvar', style: TextStyle(color: theme.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final FlutterFlowTheme theme;
  final Widget? iconWidget;

  const _SectionHeader({
    required this.title,
    required this.theme,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconWidget != null) ...[
          iconWidget!,
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: theme.titleMedium.override(fontWeight: FontWeight.w600),
        ),
      ],
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

extension ListSorted<T> on List<T> {
  List<T> sorted([int Function(T a, T b)? compare]) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }
}
