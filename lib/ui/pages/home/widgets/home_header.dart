// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/theme.dart';

class HomeHeader extends StatefulWidget {
  final List<EntradasHumorRow> recentEntries;

  const HomeHeader({super.key, required this.recentEntries});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await SupaFlow.client
          .from('app_profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted && data != null && data['avatar_url'] != null) {
        setState(() {
          _avatarUrl = data['avatar_url'] as String;
        });
      }
    } catch (e) {
      debugPrint('Error loading home header profile: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    Logger().v('HomeHeader: build called');
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date pill with glass effect
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    DateFormat(
                      "EEEE, d 'de' MMMM",
                      'pt_BR',
                    ).format(DateTime.now()).toUpperCase(),
                    style: theme.labelSmall.override(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.displaySmall.override(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 28)),
                  ],
                ),
              ],
            ),
          ),
          // User Avatar / Profile Button
          GestureDetector(
            onTap: () {
              context.pushNamed('Profile');
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.secondaryBackground,
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: _avatarUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primary,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildFallbackAvatar(theme),
                      )
                    : _buildFallbackAvatar(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(FlutterFlowTheme theme) {
    return Center(
      child: Icon(
        Icons.person_outline_rounded,
        color: theme.primaryText,
        size: 24,
      ),
    );
  }
}
