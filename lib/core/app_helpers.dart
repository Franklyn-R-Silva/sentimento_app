// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Classe com utilitários diversos para o app
class AppHelpers {
  /// Gera feedback haptico
  static void hapticFeedback({final HapticFeedbackType type = HapticFeedbackType.lightImpact}) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Copia texto para a área de transferência
  static Future<void> copyToClipboard(final String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Formata valor monetário
  static String formatCurrency(final double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata número para exibição
  static String formatNumber(final int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return '${(number / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
  }

  /// Mascara para telefone brasileiro
  static String formatPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  /// Mascara para CPF
  static String formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }

  /// Mascara para CNPJ
  static String formatCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpj.length == 14) {
      return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
    }
    return cnpj;
  }

  /// Formata CPF ou CNPJ automaticamente (detecta pelo tamanho)
  static String formatCpfCnpj(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length == 11) {
      return formatCPF(value);
    } else if (value.length == 14) {
      return formatCNPJ(value);
    }
    return value;
  }

  /// Calcula a diferença em dias entre duas datas
  static int daysBetween(final DateTime start, final DateTime end) {
    return end.difference(start).inDays;
  }

  /// Verifica se o texto está vazio ou nulo
  static bool isEmptyOrNull(final String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Retorna uma cor baseada no texto (útil para avatares)
  static Color getColorFromText(final String text) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }

  /// Gera iniciais do nome (compatível com widgets de cliente)
  static String getInitials(final String name) {
    final words = name.trim().split(' ').where((final word) => word.isNotEmpty).toList();
    if (words.isEmpty) return 'C';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0].substring(0, 1).toUpperCase() : 'C';
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  /// Debounce para pesquisas
  static Timer? _debounceTimer;
  static void debounce(final Duration delay, final VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle para evitar múltiplos taps
  static DateTime? _lastTapTime;
  static bool canTap([final Duration cooldown = const Duration(milliseconds: 500)]) {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > cooldown) {
      _lastTapTime = now;
      return true;
    }
    return false;
  }

  /// Logger simples
  static void log(final String message, {final String tag = 'APP'}) {
    debugPrint('[$tag] $message');
  }

  /// Helper para cores com transparência (evita deprecated withOpacity)
  static Color colorWithAlpha(final Color color, final double alpha) {
    return color.withValues(alpha: alpha);
  }

  /// Validadores de formulário
  static String? validateEmail(final String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validatePhone(final String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    final phoneDigits = value.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 10 || phoneDigits.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  static String? validateRequired(final String? value, [final String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validateMinLength(final String? value, final int minLength, [final String fieldName = 'Campo']) {
    if (value == null || value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }
    return null;
  }

  static String obterPrimeiroNome(final String nome) {
    if (nome.trim().isEmpty) {
      return ''; // Retorna string vazia se o nome for nulo ou vazio
    }

    // 1. Remove espaços extras no início/fim e normaliza para minúsculas
    final nomeLimpo = nome.trim().toLowerCase();

    // 2. Divide a string em uma lista de palavras usando o espaço como delimitador
    final partesDoNome = nomeLimpo.split(' ');

    // 3. O primeiro elemento da lista (índice 0) é o primeiro nome
    final primeiroNome = partesDoNome.first;

    // 4. Retorna o primeiro nome com a primeira letra em maiúsculo
    // (Apenas para garantir um formato mais padrão)
    return primeiroNome[0].toUpperCase() + primeiroNome.substring(1);
  }
}

/// Enum para tipos de feedback haptico
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}
