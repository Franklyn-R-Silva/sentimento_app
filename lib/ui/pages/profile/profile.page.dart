// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/app_card.dart';
import 'package:sentimento_app/ui/shared/widgets/app_list_tile.dart';
import 'package:sentimento_app/ui/shared/widgets/app_section_header.dart';
import 'profile.model.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_logout_button.dart';

export 'profile.model.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  static const String routeName = 'Profile';
  static const String routePath = '/profile';

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget>
    with AutomaticKeepAliveClientMixin {
  late ProfileModel _model;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
    _model.loadUserData();

    _model.changePasswordController ??= TextEditingController();
    _model.changePasswordFocusNode ??= FocusNode();
    _model.confirmPasswordController ??= TextEditingController();
    _model.confirmPasswordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure KeepAlive works
    return ChangeNotifierProvider<ProfileModel>.value(
      value: _model,
      child: Consumer<ProfileModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Perfil',
                style: theme.headlineMedium.override(color: theme.primaryText),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_rounded, color: theme.primaryText),
                  onPressed: () => context.pushNamed('Settings'),
                  tooltip: 'Configurações',
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  ProfileHeader(
                    userName: model.userName,
                    userEmail: model.userEmail,
                    avatarUrl: model.avatarUrl,
                    isUploading: model.isBusy,
                    onAvatarTap: () => model.uploadAvatarImage(context),
                  ),

                  const SizedBox(height: 32),

                  // Shortcuts Section
                  const AppSectionHeader(title: 'Minha Conta'),
                  const SizedBox(height: 12),

                  AppCard(
                    child: Column(
                      children: [
                        AppListTile(
                          icon: Icons.bar_chart_rounded,
                          title: 'Estatísticas',
                          subtitle: 'Minha evolução',
                          onTap: () => context.pushNamed('Stats'),
                        ),
                        Divider(height: 1, color: theme.alternate),
                        AppListTile(
                          icon: Icons.photo_library_rounded,
                          title: 'Galeria',
                          subtitle: 'Minhas recordações',
                          onTap: () => context.pushNamed('Gallery'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout button
                  ProfileLogoutButton(
                    onPressed: () async {
                      await model.signOut(context);
                      if (context.mounted) {
                        context.goNamed('Login');
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Danger Zone
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              title: const Text('Deletar Conta'),
                              content: const Text(
                                'Tem certeza que deseja deletar sua conta? Esta ação é irreversível e todos os seus dados serão perdidos.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    alertDialogContext,
                                  ).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    alertDialogContext,
                                  ).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Deletar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          if (!context.mounted) return;
                          await model.deleteAccount(context);
                          if (context.mounted) {
                            context.goNamed('Login');
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.red,
                      ),
                      label: Text(
                        'Deletar minha conta',
                        style: theme.bodyMedium.override(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// _SectionHeader removed
