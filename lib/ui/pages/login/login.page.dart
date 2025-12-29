import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
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
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Inter Tight',
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                  child: Text(
                    'Bem-vindo de volta',
                    style: FlutterFlowTheme.of(context).labelLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: TextFormField(
                    controller: _model.emailAddressController,
                    focusNode: _model.emailAddressFocusNode,
                    autofocus: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Endereço de Email',
                      labelStyle: FlutterFlowTheme.of(context).labelMedium,
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
                    validator: _model.emailAddressControllerValidator
                        .asValidator(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: TextFormField(
                    controller: _model.passwordController,
                    focusNode: _model.passwordFocusNode,
                    autofocus: false,
                    obscureText: !_model.passwordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: FlutterFlowTheme.of(context).labelMedium,
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
                        onTap: () => setState(
                          () => _model.passwordVisibility =
                              !_model.passwordVisibility,
                        ),
                        focusNode: FocusNode(skipTraversal: true),
                        child: Icon(
                          _model.passwordVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 24,
                        ),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                    validator: _model.passwordControllerValidator.asValidator(
                      context,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: FFButtonWidget(
                    onPressed: () async {
                      final user = await authManager.signInWithEmail(
                        context,
                        _model.emailAddressController!.text,
                        _model.passwordController!.text,
                      );
                      if (user == null) {
                        return;
                      }
                      context.goNamedAuth('HomePage', context.mounted);
                    },
                    text: 'Entrar',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: FFButtonWidget(
                    onPressed: () async {
                      final user = await authManager.createAccountWithEmail(
                        context,
                        _model.emailAddressController!.text,
                        _model.passwordController!.text,
                      );
                      if (user == null) {
                        return;
                      }
                      context.goNamedAuth('HomePage', context.mounted);
                    },
                    text: 'Criar Conta',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0,
                        0,
                        0,
                        0,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: FlutterFlowTheme.of(context).titleSmall
                          .override(
                            fontFamily: 'Inter Tight',
                            color: FlutterFlowTheme.of(context).primaryText,
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
  }
}
