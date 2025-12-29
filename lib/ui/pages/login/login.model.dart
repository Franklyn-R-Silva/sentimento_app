import 'package:flutter/material.dart';
import 'package:sentimento_app/core/model.dart';

class LoginModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressController;
  String? Function(BuildContext, String?)? emailAddressControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;
  set passwordVisibility(bool value) {
    _passwordVisibility = value;
    notifyListeners();
  }

  String? Function(BuildContext, String?)? passwordControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressController?.dispose();

    passwordFocusNode?.dispose();
    passwordController?.dispose();
    super.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
