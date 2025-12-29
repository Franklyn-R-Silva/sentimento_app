import 'package:flutter/material.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            _DrawerHeader(userName: userName, theme: theme),

            const SizedBox(height: 8),

            // Mensagem de apoio do dia
            _DailyMessage(theme: theme),

            const SizedBox(height: 16),

            // Navegação principal
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _NavSection(title: 'Sua Jornada', theme: theme),
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Início',
                    subtitle: 'Seu espaço seguro',
                    color: theme.primary,
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed('Main');
                    },
                  ),
                  _NavItem(
                    icon: Icons.book_rounded,
                    label: 'Meu Diário',
                    subtitle: 'Suas memórias e sentimentos',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('Journal');
                    },
                  ),
                  _NavItem(
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

                  _NavSection(title: 'Cuidado Pessoal', theme: theme),
                  _NavItem(
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
                  _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Afirmações Positivas',
                    subtitle: 'Palavras de conforto',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pop(context);
                      _showAffirmations(context, theme);
                    },
                  ),
                  _NavItem(
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

                  _NavSection(title: 'Configurações', theme: theme),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Configurações',
                    subtitle: 'Tema, notificações e mais',
                    color: const Color(0xFF607D8B),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  _NavItem(
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
              child: _LogoutButton(theme: theme),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreathingExercise(BuildContext context, FlutterFlowTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BreathingExerciseSheet(theme: theme),
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

    showDialog(
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withAlpha(40),
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
            _EmergencyContact(
              name: 'CVV - Ligue 188',
              description: 'Apoio emocional 24 horas',
              color: const Color(0xFFE53935),
              theme: theme,
            ),
            const SizedBox(height: 12),
            _EmergencyContact(
              name: 'SAMU - Ligue 192',
              description: 'Emergências médicas',
              color: const Color(0xFF2196F3),
              theme: theme,
            ),
            const SizedBox(height: 12),
            _EmergencyContact(
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

class _DrawerHeader extends StatelessWidget {
  final String userName;
  final FlutterFlowTheme theme;

  const _DrawerHeader({required this.userName, required this.theme});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary.withAlpha(50), theme.secondary.withAlpha(30)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withAlpha(100),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: theme.headlineSmall.override(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: theme.labelMedium.override(color: theme.secondaryText),
                ),
                Text(
                  userName,
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyMessage extends StatelessWidget {
  final FlutterFlowTheme theme;

  const _DailyMessage({required this.theme});

  String _getMessage() {
    final messages = [
      'Cada dia é uma nova oportunidade 🌅',
      'Você está fazendo um ótimo trabalho 🌟',
      'Pequenos passos fazem grandes jornadas 🚶',
      'Respire fundo. Você está bem 🌸',
      'Sua presença ilumina o mundo 🌻',
      'Seja gentil consigo mesmo hoje 💜',
      'Você é mais resiliente do que pensa 💪',
    ];
    return messages[DateTime.now().weekday % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary.withAlpha(30), theme.tertiary.withAlpha(20)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Text('💫', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getMessage(),
              style: theme.bodySmall.override(
                fontStyle: FontStyle.italic,
                color: theme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  final String title;
  final FlutterFlowTheme theme;

  const _NavSection({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: theme.labelSmall.override(
          color: theme.secondaryText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final bool isEmergency;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isEmergency ? color.withAlpha(25) : theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: isEmergency ? Border.all(color: color.withAlpha(100)) : null,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: theme.labelSmall.override(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: theme.labelSmall.override(color: theme.secondaryText),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.secondaryText,
          size: 20,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final FlutterFlowTheme theme;

  const _LogoutButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        Navigator.pop(context);
        await authManager.signOut();
        if (context.mounted) {
          context.goNamed('Login');
        }
      },
      icon: Icon(Icons.logout_rounded, color: theme.error, size: 20),
      label: Text(
        'Sair',
        style: theme.labelMedium.override(color: theme.error),
      ),
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  final String name;
  final String description;
  final Color color;
  final FlutterFlowTheme theme;

  const _EmergencyContact({
    required this.name,
    required this.description,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.bodyMedium.override(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: theme.labelSmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreathingExerciseSheet extends StatefulWidget {
  final FlutterFlowTheme theme;

  const _BreathingExerciseSheet({required this.theme});

  @override
  State<_BreathingExerciseSheet> createState() =>
      _BreathingExerciseSheetState();
}

class _BreathingExerciseSheetState extends State<_BreathingExerciseSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = 'Inspire';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = 'Expire');
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = 'Inspire');
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExercise() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text('Exercício de Respiração', style: theme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Relaxe e siga o ritmo',
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 200 * _animation.value,
                        height: 200 * _animation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.primary.withAlpha(150),
                              theme.secondary.withAlpha(100),
                              theme.tertiary.withAlpha(50),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withAlpha(80),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _isRunning ? _instruction : 'Toque para iniciar',
                            textAlign: TextAlign.center,
                            style: theme.titleMedium.override(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? theme.error : theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  _isRunning ? 'Parar' : 'Começar',
                  style: theme.titleSmall.override(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
