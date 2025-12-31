import 'package:flutter/material.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/exceptions/app_exceptions.dart';
import 'package:sentimento_app/services/toast_service.dart';

/// Base Model que fornece funcionalidades comuns como gerenciamento de estado
/// de carregamento (busy/idle) e tratamento de erros seguro (runSafe).
abstract class BaseModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  /// Define o estado de carregamento e notifica os ouvintes
  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  /// Executa uma ação assíncrona com tratamento de erros centralizado.
  ///
  /// [action]: A função assíncrona a ser executada.
  /// [showErrorToast]: Se true, exibe um toast de erro automaticamente.
  /// [rethrowError]: Se true, repassa o erro após o tratamento (útil se quem chamou precisa saber).
  Future<void> runSafe(
    Future<void> Function() action, {
    bool showErrorToast = true,
    bool rethrowError = false,
  }) async {
    try {
      setBusy(true);
      await action();
    } on AppException catch (e) {
      if (showErrorToast) {
        if (e is ValidationException) {
          ToastService.showWarning(e.message);
        } else if (e is AuthException) {
          ToastService.showError(e.message);
        } else {
          ToastService.showError(e.message);
        }
      }
      if (rethrowError) rethrow;
    } catch (e) {
      if (showErrorToast) {
        ToastService.showError('Ocorreu um erro inesperado: $e');
      }
      debugPrint('Generic Error in runSafe: $e');
      if (rethrowError) rethrow;
    } finally {
      setBusy(false);
    }
  }
}
