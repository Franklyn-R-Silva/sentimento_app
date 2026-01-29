// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/services/notification_service.dart';
import 'package:sentimento_app/services/toast_service.dart';
import 'package:sentimento_app/ui/shared/widgets/app_card.dart';
import 'package:sentimento_app/ui/shared/widgets/app_list_tile.dart';
import 'package:sentimento_app/ui/shared/widgets/app_section_header.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

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
          'Área de Testes',
          style: theme.headlineMedium.override(color: theme.primaryText),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppSectionHeader(title: '🔔 Notificações'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    icon: Icons.notifications_active_rounded,
                    iconColor: const Color(0xFFFFC107),
                    title: 'Disparar Notificação Instantânea',
                    subtitle: 'Testa se as permissões e o serviço estão ativos',
                    onTap: () async {
                      await NotificationService().showInstantNotification(
                        id: 999,
                        title: 'Teste Visual 🎨',
                        body:
                            'Verificando aparência da notificação no Android.',
                        payload: 'debug',
                      );
                      ToastService.showSuccess('Enviada!');
                    },
                  ),
                  const Divider(height: 1),
                  AppListTile(
                    icon: Icons.timer_rounded,
                    iconColor: Colors.blue,
                    title: 'Agendar para daqui a 5s',
                    subtitle: 'Testa o agendamento local',
                    onTap: () async {
                      // Simple delay test
                      Future.delayed(const Duration(seconds: 5), () {
                        NotificationService().showInstantNotification(
                          id: 1000,
                          title: 'Teste Agendado ⏱️',
                          body: 'Apareceu 5 segundos depois!',
                        );
                      });
                      ToastService.showInfo('Aguarde 5 segundos...');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const AppSectionHeader(title: '🎨 Testes Visuais'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    icon: Icons.palette_rounded,
                    iconColor: Colors.purple,
                    title: 'Cores do Tema',
                    subtitle: 'Visualizar paleta de cores atual',
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: theme.secondaryBackground,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Paleta Atual', style: theme.headlineSmall),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _ColorBox('Primary', theme.primary),
                                  _ColorBox('Secondary', theme.secondary),
                                  _ColorBox('Tertiary', theme.tertiary),
                                  _ColorBox('Alternate', theme.alternate),
                                  _ColorBox(
                                    'Background',
                                    theme.primaryBackground,
                                  ),
                                  _ColorBox(
                                    'Sec. BG',
                                    theme.secondaryBackground,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  AppListTile(
                    icon: Icons.font_download_rounded,
                    iconColor: Colors.teal,
                    title: 'Tipografia',
                    subtitle: 'Visualizar estilos de texto',
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: theme.secondaryBackground,
                        isScrollControlled: true,
                        builder: (context) => DraggableScrollableSheet(
                          expand: false,
                          builder: (context, scrollController) => ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            children: [
                              Text(
                                'Headline Large',
                                style: theme.headlineLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Headline Medium',
                                style: theme.headlineMedium,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Headline Small',
                                style: theme.headlineSmall,
                              ),
                              const SizedBox(height: 20),
                              Text('Title Large', style: theme.titleLarge),
                              Text('Title Medium', style: theme.titleMedium),
                              Text('Title Small', style: theme.titleSmall),
                              const SizedBox(height: 20),
                              Text('Body Large', style: theme.bodyLarge),
                              Text('Body Medium', style: theme.bodyMedium),
                              Text('Body Small', style: theme.bodySmall),
                              const SizedBox(height: 20),
                              Text('Label Large', style: theme.labelLarge),
                              Text('Label Medium', style: theme.labelMedium),
                              Text('Label Small', style: theme.labelSmall),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorBox(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
