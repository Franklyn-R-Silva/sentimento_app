import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/backend/supabase.dart';

class DrawerHeaderWidget extends StatefulWidget {
  final String userName;
  final FlutterFlowTheme theme;

  const DrawerHeaderWidget({
    super.key,
    required this.userName,
    required this.theme,
  });

  @override
  State<DrawerHeaderWidget> createState() => _DrawerHeaderWidgetState();
}

class _DrawerHeaderWidgetState extends State<DrawerHeaderWidget> {
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
      debugPrint('Error loading drawer profile: $e');
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.theme.primary.withValues(alpha: 0.2),
            widget.theme.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.theme.primary, widget.theme.secondary],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(_avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                ? Center(
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : 'U',
                      style: widget.theme.headlineSmall.override(
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: widget.theme.labelMedium.override(
                    color: widget.theme.secondaryText,
                  ),
                ),
                Text(
                  widget.userName,
                  style: widget.theme.titleMedium.override(
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
