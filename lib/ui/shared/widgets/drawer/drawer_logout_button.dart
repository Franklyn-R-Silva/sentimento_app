import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/core/nav/nav.dart';

class DrawerLogoutButton extends StatelessWidget {
  final FlutterFlowTheme theme;

  const DrawerLogoutButton({super.key, required this.theme});

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
