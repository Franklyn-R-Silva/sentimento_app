import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/widgets.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/nav/nav.dart';
import 'login.model.dart';

export 'login.model.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginModel>.value(
      value: _model,
      child: Consumer<LoginModel>(
        builder: (context, model, child) {
          return GestureDetector(
            onTap: () => model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: SafeArea(
                top: true,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sentimento',
                        style: FlutterFlowTheme.of(context).displaySmall
                            .override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          12,
                          0,
                          24,
                        ),
                        child: Text(
                          'Bem-vindo de volta',
                          style: FlutterFlowTheme.of(context).labelLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
                        child: TextFormField(
                          controller: model.emailAddressController,
                          focusNode: model.emailAddressFocusNode,
                          autofocus: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Endereço de Email',
                            labelStyle: FlutterFlowTheme.of(
                              context,
                            ).labelMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(
                              context,
                            ).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          keyboardType: TextInputType.emailAddress,
                          validator: model.emailAddressControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
                        child: TextFormField(
                          controller: model.passwordController,
                          focusNode: model.passwordFocusNode,
                          autofocus: false,
                          obscureText: !model.passwordVisibility,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: FlutterFlowTheme.of(
                              context,
                            ).labelMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(
                              context,
                            ).secondaryBackground,
                            suffixIcon: InkWell(
                              onTap: () => model.passwordVisibility =
                                  !model.passwordVisibility,
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                model.passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryText,
                                size: 24,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          validator: model.passwordControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (model.isLoading) return;
                            model.isLoading = true;
                            try {
                              final user = await authManager.signInWithEmail(
                                context,
                                model.emailAddressController!.text,
                                model.passwordController!.text,
                              );
                              if (user == null) {
                                return;
                              }
                              if (context.mounted) {
                                context.goNamedAuth(
                                  'HomePage',
                                  context.mounted,
                                );
                              }
                            } finally {
                              model.isLoading = false;
                            }
                          },
                          text: model.isLoading ? 'Carregando...' : 'Entrar',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              0,
                              0,
                              0,
                              0,
                            ),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0,
                              0,
                              0,
                              0,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                ),
                            elevation: 3,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (model.isLoading) return;
                            model.isLoading = true;
                            try {
                              final user = await authManager
                                  .createAccountWithEmail(
                                    context,
                                    model.emailAddressController!.text,
                                    model.passwordController!.text,
                                  );
                              if (user == null) {
                                return;
                              }
                              if (context.mounted) {
                                context.goNamedAuth(
                                  'HomePage',
                                  context.mounted,
                                );
                              }
                            } finally {
                              model.isLoading = false;
                            }
                          },
                          text: model.isLoading
                              ? 'Criando Conta...'
                              : 'Criar Conta',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              0,
                              0,
                              0,
                              0,
                            ),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0,
                              0,
                              0,
                              0,
                            ),
                            color: FlutterFlowTheme.of(
                              context,
                            ).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryText,
                                ),
                            elevation: 0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
