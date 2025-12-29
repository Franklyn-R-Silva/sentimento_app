import 'package:flutter/material.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'drawer/drawer_header.dart';
import 'drawer/daily_message.dart';
import 'drawer/drawer_nav_section.dart';
import 'drawer/drawer_nav_item.dart';
import 'drawer/drawer_logout_button.dart';
import 'drawer/emergency_contact.dart';
import 'drawer/breathing_exercise_sheet.dart';

/// AppDrawer - Drawer inventivo e acolhedor para usuários com depressão
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final String userName =
        (user?.userMetadata?['name'] as String?) ??
        user?.email?.split('@').first ??
        'Amigo';

    return Drawer(
      backgroundColor: theme.primaryBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header acolhedor
            DrawerHeaderWidget(userName: userName, theme: theme),

            const SizedBox(height: 8),

            // Mensagem de apoio do dia
            DailyMessage(theme: theme),

            const SizedBox(height: 16),

            // Navegação principal
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  DrawerNavSection(title: 'Sua Jornada', theme: theme),
                  DrawerNavItem(
                    icon: Icons.home_rounded,
                    label: 'Início',
                    subtitle: 'Seu espaço seguro',
                    color: theme.primary,
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed('Main');
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.book_rounded,
                    label: 'Meu Diário',
                    subtitle: 'Suas memórias e sentimentos',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('Journal');
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Minha Evolução',
                    subtitle: 'Veja seu progresso',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('Stats');
                    },
                  ),

                  const SizedBox(height: 16),

                  DrawerNavSection(title: 'Cuidado Pessoal', theme: theme),
                  DrawerNavItem(
                    icon: Icons.spa_rounded,
                    label: 'Exercícios de Calma',
                    subtitle: 'Respiração e meditação',
                    color: const Color(0xFF9C27B0),
                    badge: 'Novo',
                    onTap: () {
                      Navigator.pop(context);
                      _showBreathingExercise(context, theme);
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Afirmações Positivas',
                    subtitle: 'Palavras de conforto',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pop(context);
                      _showAffirmations(context, theme);
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.phone_in_talk_rounded,
                    label: 'Preciso de Ajuda',
                    subtitle: 'CVV: 188 (24 horas)',
                    color: const Color(0xFFE53935),
                    isEmergency: true,
                    onTap: () {
                      _showEmergencyDialog(context, theme);
                    },
                  ),

                  const SizedBox(height: 16),

                  DrawerNavSection(title: 'Configurações', theme: theme),
                  DrawerNavItem(
                    icon: Icons.settings_rounded,
                    label: 'Configurações',
                    subtitle: 'Tema, notificações e mais',
                    color: const Color(0xFF607D8B),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.person_rounded,
                    label: 'Meu Perfil',
                    subtitle: 'Suas informações',
                    color: const Color(0xFF795548),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('Profile');
                    },
                  ),
                ],
              ),
            ),

            // Footer com logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: DrawerLogoutButton(theme: theme),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreathingExercise(BuildContext context, FlutterFlowTheme theme) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BreathingExerciseSheet(theme: theme),
    );
  }

  void _showAffirmations(BuildContext context, FlutterFlowTheme theme) {
    final affirmations = [
      'Você é mais forte do que imagina 💪',
      'Está tudo bem não estar bem às vezes 🌈',
      'Você merece amor e compaixão 💜',
      'Um dia de cada vez. Você consegue 🌱',
      'Seus sentimentos são válidos 🤗',
      'Você é importante e faz diferença ⭐',
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💜', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              affirmations[DateTime.now().day % affirmations.length],
              textAlign: TextAlign.center,
              style: theme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Obrigado 💜',
                  style: theme.titleSmall.override(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context, FlutterFlowTheme theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 12),
            Text('Você não está sozinho', style: theme.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se você está passando por um momento difícil, saiba que há pessoas que querem ajudar.',
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 20),
            EmergencyContact(
              name: 'CVV - Ligue 188',
              description: 'Apoio emocional 24 horas',
              color: const Color(0xFFE53935),
              theme: theme,
            ),
            const SizedBox(height: 12),
            EmergencyContact(
              name: 'SAMU - Ligue 192',
              description: 'Emergências médicas',
              color: const Color(0xFF2196F3),
              theme: theme,
            ),
            const SizedBox(height: 12),
            EmergencyContact(
              name: 'Chat CVV',
              description: 'www.cvv.org.br',
              color: const Color(0xFF4CAF50),
              theme: theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: TextStyle(color: theme.primary)),
          ),
        ],
      ),
    );
  }
}
