// ignore_for_file: overridden_fields, annotate_overrides

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class FlutterFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.light
        : darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static void saveThemeMode(final ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(final BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // Cores principais - tema roxo profissional
  late Color primary = const Color(0xFF7C4DFF); // Roxo vibrante
  late Color secondary = const Color(0xFF9C7CF2); // Roxo mais claro
  late Color tertiary = const Color(0xFFB388FF); // Lavanda
  late Color alternate = const Color(0xFFE8E0F0); // Roxo bem claro para bordas

  // Textos - escuros no modo claro
  late Color primaryText = const Color(0xFF1A1A2E); // Texto principal escuro
  late Color secondaryText = const Color(0xFF666680); // Texto secundário

  // Fundos - claros no modo claro
  late Color primaryBackground = const Color(
    0xFFF8F6FC,
  ); // Fundo com tom roxo sutil
  late Color secondaryBackground = const Color(0xFFFFFFFF); // Cards brancos

  // Acentos (uso sutil)
  late Color accent1 = const Color(0x337C4DFF); // Roxo 20%
  late Color accent2 = const Color(0x339C7CF2); // Roxo claro 20%
  late Color accent3 = const Color(0x33B388FF); // Lavanda 20%
  late Color accent4 = const Color(0x66E8E0F0); // Roxo bem claro 40%

  // Estados
  late Color success = const Color(0xFF4CAF50); // Verde sucesso
  late Color warning = const Color(0xFFFF9800); // Laranja alerta
  late Color error = const Color(0xFFE53935); // Vermelho erro
  late Color info = const Color(0xFF5E35B1); // Roxo escuro info
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Inter Tight';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 64,
  );
  String get displayMediumFamily => 'Inter Tight';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 44,
  );
  String get displaySmallFamily => 'Inter Tight';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 36,
  );
  String get headlineLargeFamily => 'Inter Tight';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 32,
  );
  String get headlineMediumFamily => 'Inter Tight';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 28,
  );
  String get headlineSmallFamily => 'Inter Tight';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );
  String get titleLargeFamily => 'Inter Tight';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 20,
  );
  String get titleMediumFamily => 'Inter Tight';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );
  String get titleSmallFamily => 'Inter Tight';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => TextStyle(
    fontFamily: 'InterTight',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );
  String get labelLargeFamily => 'Inter';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => TextStyle(
    fontFamily: 'Roboto',
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );
  String get labelMediumFamily => 'Inter';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => TextStyle(
    fontFamily: 'Roboto',
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
  String get labelSmallFamily => 'Inter';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => TextStyle(
    fontFamily: 'Roboto',
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 12,
  );
  String get bodyLargeFamily => 'Inter';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => TextStyle(
    fontFamily: 'Roboto',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );
  String get bodyMediumFamily => 'Inter';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Roboto',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
  String get bodySmallFamily => 'Inter';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => TextStyle(
    fontFamily: 'Roboto',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 12,
  );
}

class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // Cores principais - tema roxo profissional
  late Color primary = const Color(
    0xFF9C7CF2,
  ); // Roxo mais claro para destaque no escuro
  late Color secondary = const Color(0xFFB388FF); // Lavanda
  late Color tertiary = const Color(0xFFCE93D8); // Rosa lavanda
  late Color alternate = const Color(
    0xFF3D3A50,
  ); // Roxo acinzentado para bordas

  // Textos - claros no modo escuro
  late Color primaryText = const Color(0xFFF5F5F7); // Texto principal claro
  late Color secondaryText = const Color(0xFFB8B8C7); // Texto secundário

  // Fundos - NÃO muito escuros (cinza médio com tom roxo)
  late Color primaryBackground = const Color(
    0xFF1E1B2E,
  ); // Fundo principal (roxo escuro suave)
  late Color secondaryBackground = const Color(
    0xFF2D2A3E,
  ); // Cards (roxo escuro mais claro)

  // Acentos (uso sutil)
  late Color accent1 = const Color(0x409C7CF2); // Roxo 25%
  late Color accent2 = const Color(0x40B388FF); // Lavanda 25%
  late Color accent3 = const Color(0x40CE93D8); // Rosa lavanda 25%
  late Color accent4 = const Color(0x663D3A50); // Roxo acinzentado 40%

  // Estados
  late Color success = const Color(0xFF66BB6A); // Verde mais claro
  late Color warning = const Color(0xFFFFB74D); // Laranja mais claro
  late Color error = const Color(0xFFEF5350); // Vermelho mais claro
  late Color info = const Color(0xFF7E57C2); // Roxo info
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    final TextStyle? font,
    final String? fontFamily,
    final Color? color,
    final double? fontSize,
    final FontWeight? fontWeight,
    final double? letterSpacing,
    final FontStyle? fontStyle,
    final TextDecoration? decoration,
    final double? lineHeight,
    final List<Shadow>? shadows,
    final String? package,
  }) {
    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
