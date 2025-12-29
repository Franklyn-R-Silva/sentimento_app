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

  // New fields for Create Account
  bool _isCreateAccount = false;
  bool get isCreateAccount => _isCreateAccount;
  set isCreateAccount(bool value) {
    _isCreateAccount = value;
    notifyListeners();
  }

  FocusNode? usernameFocusNode;
  TextEditingController? usernameController;
  String? Function(BuildContext, String?)? usernameControllerValidator;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;
  set passwordVisibility(bool value) {
    _passwordVisibility = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
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

    usernameFocusNode?.dispose();
    usernameController?.dispose();
    super.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
