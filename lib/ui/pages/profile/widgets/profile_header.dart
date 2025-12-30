// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class ProfileHeader extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    this.userName,
    this.userEmail,
    this.avatarUrl,
    this.isUploading = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withValues(alpha: 0.2),
            theme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: isUploading ? null : onAvatarTap,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.primary, theme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? Image.network(
                            avatarUrl!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildInitials(theme);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : _buildInitials(theme),
                  ),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                if (!isUploading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.primaryBackground,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(userName ?? 'Usuário', style: theme.titleLarge),
          const SizedBox(height: 4),
          Text(
            userEmail ?? '',
            style: theme.labelMedium.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(FlutterFlowTheme theme) {
    String initials = 'U';
    if (userName != null && userName!.trim().isNotEmpty) {
      final names = userName!.trim().split(' ');
      if (names.length > 1) {
        initials = (names.first[0] + names.last[0]).toUpperCase();
      } else {
        initials = names.first[0].toUpperCase();
      }
    }

    return Center(
      child: Text(
        initials,
        style: theme.displaySmall.override(color: Colors.white),
      ),
    );
  }
}
