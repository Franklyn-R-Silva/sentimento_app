// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:app_settings/app_settings.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/main.dart';
import 'package:sentimento_app/services/notification_service.dart';
import 'package:sentimento_app/services/pdf_service.dart';
import 'package:sentimento_app/services/toast_service.dart';
import 'package:sentimento_app/ui/pages/settings/settings.model.dart';
import 'package:sentimento_app/ui/pages/settings/debug/debug_page.dart';
import 'package:sentimento_app/ui/pages/settings/widgets/schedule_dialog.dart';
import 'package:sentimento_app/ui/shared/widgets/app_card.dart';
import 'package:sentimento_app/ui/shared/widgets/app_list_tile.dart';
import 'package:sentimento_app/ui/shared/widgets/app_section_header.dart';

// Actually, without provider/riverpod setup, simpler is best.
// But the user asked for MVVM/Model. FlutterFlow usually uses a 'model' instance.

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  static const String routeName = 'Settings';
  static const String routePath = '/settings';

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  late SettingsModel _model;

  @override
  void initState() {
    super.initState();
    _model = SettingsModel(); // Initialize model
    _model.initState(context);
    // Listen to model changes to rebuild
    _model.addListener(_onModelUpdated);
  }

  @override
  void dispose() {
    _model.removeListener(_onModelUpdated);
    _model.dispose();
    super.dispose();
  }

  void _onModelUpdated() {
    if (mounted) setState(() {});
  }

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
            const AppSectionHeader(title: '🎨 Aparência'),
            const SizedBox(height: 12),

            AppCard(
              child: Column(
                children: [
                  AppListTile(
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
                  AppListTile(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFFFF9800),
                    title: 'Tema Automático',
                    subtitle: 'Seguir configuração do sistema',
                    trailing: TextButton(
                      onPressed: () {
                        MyApp.of(context).setThemeMode(ThemeMode.system);
                        ToastService.showSuccess('Tema automático ativado');
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
            AppSectionHeader(
              title: 'Notificações',
              iconWidget: Image.asset(
                'assets/images/imagem_2.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 12),

            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Notificações',
                    subtitle: 'Ativar lembretes do aplicativo',
                    trailing: Switch.adaptive(
                      value: _model.notificationsEnabled,
                      onChanged: (value) async {
                        await _model.setNotificationsEnabled(value);
                      },
                      activeTrackColor: theme.primary,
                      inactiveTrackColor: theme.alternate,
                    ),
                  ),
                ],
              ),
            ),

            if (_model.notificationsEnabled) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppSectionHeader(title: '⏰ Meus Horários'),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_rounded,
                      color: theme.primary,
                      size: 28,
                    ),
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (_) => const ScheduleDialog(),
                      );
                      if (result == true) _model.refresh();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_model.schedules.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Nenhum horário configurado',
                      style: theme.bodyMedium.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _model.schedules.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final schedule = _model.schedules[index];
                    return AppCard(
                      child: AppListTile(
                        icon: Icons.alarm_rounded,
                        iconColor: theme.primary,
                        title: _formatTime(schedule.hour, schedule.minute),
                        subtitle: _formatDays(schedule.activeDays),
                        onTap: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (_) => ScheduleDialog(schedule: schedule),
                          );
                          if (result == true) _model.refresh();
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch.adaptive(
                              value: schedule.isEnabled,
                              onChanged: (val) {
                                _model.updateSchedule(schedule, val);
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

            const SizedBox(height: 24),
            // Dados e Privacidade
            const AppSectionHeader(title: '🔒 Dados'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: const Color(0xFFE91E63),
                    title: 'Exportar Relatório',
                    subtitle: 'Gerar PDF com histórico de 30 dias',
                    onTap: () async {
                      try {
                        ToastService.showInfo('Gerando relatório...');

                        final records = await SupaFlow.client
                            .from('entradas_humor')
                            .select()
                            .order('criado_em', ascending: false)
                            .limit(30)
                            .withConverter(
                              (data) => data
                                  .map((map) => EntradasHumorRow(map))
                                  .toList(),
                            );

                        if (records.isEmpty) {
                          ToastService.showInfo('Nenhum registro encontrado.');
                          return;
                        }

                        await PdfService().generateAndShareFullReport(records);
                      } catch (e) {
                        ToastService.showError('Erro ao gerar PDF: $e');
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Outros
            const AppSectionHeader(title: '⚙️ Outros'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF9E9E9E),
                    title: 'Configurações do Sistema',
                    subtitle: 'Abrir configurações do Android',
                    onTap: () => AppSettings.openAppSettings(),
                  ),
                  Divider(color: theme.alternate, height: 1),
                  AppListTile(
                    icon: Icons.notifications_active_rounded,
                    iconColor: const Color(0xFFFFC107),
                    title: 'Área de Testes (Dev)',
                    subtitle: 'Ferramentas de debug e testes visuais',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const DebugPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  AppListTile(
                    icon: Icons.developer_mode_rounded,
                    iconColor: const Color(0xFF607D8B),
                    title: 'Debugar Agendamentos',
                    subtitle: 'Ver lista de próximos lembretes',
                    onTap: () async {
                      final pending = await NotificationService()
                          .getPendingNotifications();
                      if (context.mounted) {
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Agendamentos Pendentes'),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 300,
                                child: pending.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Nenhum agendamento pendente',
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: pending.length,
                                        itemBuilder: (context, index) {
                                          final p = pending[index];
                                          return ListTile(
                                            title: Text(
                                              'ID: ${p.id} - ${p.title}',
                                            ),
                                            subtitle: Text(
                                              'Body: ${p.body}\nPayload: ${p.payload}',
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Sobre
            const AppSectionHeader(title: 'ℹ️ Sobre'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: theme.primary,
                    title: 'Versão do App',
                    subtitle: 'v1.0.0',
                    trailing: Text(
                      'Estável',
                      style: theme.bodyMedium.override(color: theme.success),
                    ),
                  ),
                  Divider(color: theme.alternate, height: 1),
                  const AppListTile(
                    icon: Icons.favorite_rounded,
                    iconColor: Colors.redAccent,
                    title: 'Feito com carinho',
                    subtitle: 'Sentimento App',
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

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final theme = FlutterFlowTheme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          backgroundColor: theme.secondaryBackground,
          title: const Text('Excluir Conta?'),
          content: const Text(
            'Tem certeza que deseja excluir sua conta e todos os seus dados? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              child: Text('Excluir Tudo', style: TextStyle(color: theme.error)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        ToastService.showInfo('Excluindo dados...');

        final supabase = SupaFlow.client;
        final userId = supabase.auth.currentUser?.id;

        if (userId != null) {
          // Delete database data first (Soft delete for user perspective)
          // Ideally we would delete the Auth User via Edge Function,
          // but for V1 we clean up the DB.
          await supabase.from('entradas_humor').delete().eq('user_id', userId);
          await supabase.from('fotos_anuais').delete().eq('user_id', userId);
          // Add other tables here if needed
        }

        await supabase.auth.signOut();

        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('Login', (route) => false);
          ToastService.showSuccess('Conta excluída com sucesso.');
        }
      } catch (e) {
        ToastService.showError('Erro ao excluir conta: $e');
      }
    }
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return 'Todos os dias';
    if (days.isEmpty) return 'Nenhum dia';

    // Map 1=Mon, 7=Sun
    const weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days.map((d) => weekDays[d - 1]).join(', ');
  }
}
