// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'package:sentimento_app/core/theme.dart';
import 'login.model.dart';

export 'login.model.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  static const String routeName = 'Login';
  static const String routePath = '/login';

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget>
    with SingleTickerProviderStateMixin {
  late LoginModel _model;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.usernameController ??= TextEditingController();
    _model.usernameFocusNode ??= FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginModel>.value(
      value: _model,
      child: Consumer<LoginModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primary.withValues(alpha: 0.1),
                      theme.primaryBackground,
                      theme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),

                          // Logo/Icon
                          Container(
                            width: 100,
                            height: 100,
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
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('😊', style: TextStyle(fontSize: 48)),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // App name
                          Text(
                            'Sentimento',
                            style: theme.displaySmall.override(
                              fontFamily: 'Inter Tight',
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Acompanhe seu humor diariamente',
                            style: theme.bodyMedium.override(
                              color: theme.secondaryText,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Username field (Create Account only)
                          if (model.isCreateAccount) ...[
                            _buildTextField(
                              context: context,
                              controller: model.usernameController!,
                              focusNode: model.usernameFocusNode!,
                              label: 'Nome de Usuário',
                              hint: 'usuario123',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email field
                          _buildTextField(
                            context: context,
                            controller: model.emailAddressController!,
                            focusNode: model.emailAddressFocusNode!,
                            label: 'Email',
                            hint: 'seu@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          _buildTextField(
                            context: context,
                            controller: model.passwordController!,
                            focusNode: model.passwordFocusNode!,
                            label: 'Senha',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            passwordVisible: model.passwordVisibility,
                            onTogglePassword: () => model.passwordVisibility =
                                !model.passwordVisibility,
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: model.isLoading
                                  ? null
                                  : () async {
                                      final success = model.isCreateAccount
                                          ? await model.createAccount(context)
                                          : await model.login(context);
                                      if (success && context.mounted) {
                                        context.goNamedAuth('Main', true);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: model.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      model.isCreateAccount
                                          ? 'Criar Conta'
                                          : 'Entrar',
                                      style: theme.titleSmall.override(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Toggle mode button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: TextButton(
                              onPressed: () {
                                model.isCreateAccount = !model.isCreateAccount;
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.secondaryText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: theme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: model.isCreateAccount
                                          ? 'Já tem uma conta? '
                                          : 'Não tem uma conta? ',
                                    ),
                                    TextSpan(
                                      text: model.isCreateAccount
                                          ? 'Faça Login'
                                          : 'Crie uma agora',
                                      style: TextStyle(
                                        color: theme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: theme.alternate)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'ou continue com',
                                  style: theme.labelSmall.override(
                                    color: theme.secondaryText,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: theme.alternate)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Social login buttons (UI only)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Em breve!'),
                                      backgroundColor: theme.primary,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              _SocialButton(
                                icon: Icons.apple_rounded,
                                label: 'Apple',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Em breve!'),
                                      backgroundColor: theme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool passwordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !passwordVisible,
      keyboardType: keyboardType,
      style: theme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: theme.labelMedium.override(color: theme.secondaryText),
        hintStyle: theme.bodyMedium.override(
          color: theme.secondaryText.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, color: theme.secondaryText),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.secondaryText,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: theme.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryText, size: 24),
            const SizedBox(width: 8),
            Text(label, style: theme.labelMedium),
          ],
        ),
      ),
    );
  }
}
