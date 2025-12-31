// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/theme.dart';

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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: _avatarUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        debugPrint(
                          'CachedNetworkImage error: $error for URL: $url',
                        );
                        return Center(
                          child: AutoSizeText(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'U',
                            style: widget.theme.headlineSmall.override(
                              color: Colors.white,
                            ),
                            minFontSize: 10,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: AutoSizeText(
                        widget.userName.isNotEmpty
                            ? widget.userName[0].toUpperCase()
                            : 'U',
                        style: widget.theme.headlineSmall.override(
                          color: Colors.white,
                        ),
                        minFontSize: 10,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  _getGreeting(),
                  style: widget.theme.labelMedium.override(
                    color: widget.theme.secondaryText,
                  ),
                  minFontSize: 9,
                ),
                AutoSizeText(
                  widget.userName,
                  style: widget.theme.titleMedium.override(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  minFontSize: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
