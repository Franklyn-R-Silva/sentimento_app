/// Classe base para todas as exceções do aplicativo
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Erros relacionados a autenticação (login, senha incorreta, etc)
class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

/// Erros de validação de dados (campos vazios, formato inválido)
class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

/// Erros de infraestrutura (rede, banco de dados, servidor)
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Erros inesperados ou não categorizados
class GenericException extends AppException {
  GenericException([String message = 'Ocorreu um erro inesperado.'])
    : super(message);
}
