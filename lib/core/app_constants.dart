class AppConstants {
  // Informações do App
  static const String appName = 'Coagro';
  static const String enterpriseName = 'Grupo Coagro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema de Gestão Empresarial';
  static const List<String> filiaisRestritas = ['31', '99', '17'];

  // Configurações de Layout
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double defaultBorderRadius = 8;
  static const double largeBorderRadius = 16;

  // Configurações de Animação
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Configurações de Timeout
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(milliseconds: 2000);

  // Strings de UI
  static const String loadingText = 'Carregando...';
  static const String errorGenericMessage = 'Ocorreu um erro inesperado';
  static const String noInternetMessage = 'Sem conexão com a internet';
  static const String tryAgainText = 'Tentar novamente';
  static const String cancelText = 'Cancelar';
  static const String confirmText = 'Confirmar';
  static const String saveText = 'Salvar';
  static const String editText = 'Editar';
  static const String deleteText = 'Excluir';

  // Breakpoints responsivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Configurações de imagens
  static const String defaultImagePath = 'assets/images/';
  static const String logoPath = 'assets/images/logo.jpg';

  // Configurações de cache
  static const int maxCacheSize = 50; // MB
  static const Duration cacheExpiration = Duration(hours: 24);

  // Lista de siglas dos estados brasileiros
  static const List<String> siglasEstadosBrasil = [
    'AC', // Acre
    'AL', // Alagoas
    'AP', // Amapá
    'AM', // Amazonas
    'BA', // Bahia
    'CE', // Ceará
    'DF', // Distrito Federal
    'ES', // Espírito Santo
    'GO', // Goiás
    'MA', // Maranhão
    'MT', // Mato Grosso
    'MS', // Mato Grosso do Sul
    'MG', // Minas Gerais
    'PA', // Pará
    'PB', // Paraíba
    'PR', // Paraná
    'PE', // Pernambuco
    'PI', // Piauí
    'RJ', // Rio de Janeiro
    'RN', // Rio Grande do Norte
    'RS', // Rio Grande do Sul
    'RO', // Rondônia
    'RR', // Roraima
    'SC', // Santa Catarina
    'SP', // São Paulo
    'SE', // Sergipe
    'TO', // Tocantins
  ];
}

/// Enum para tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Helper class para detectar tipo de dispositivo
class DeviceUtils {
  static DeviceType getDeviceType(final double width) {
    if (width < AppConstants.mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < AppConstants.tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(final double width) => getDeviceType(width) == DeviceType.mobile;
  static bool isTablet(final double width) => getDeviceType(width) == DeviceType.tablet;
  static bool isDesktop(final double width) => getDeviceType(width) == DeviceType.desktop;
}
