// ignore_for_file: strict_raw_type

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

// Project imports:
import 'package:sentimento_app/core/app_constants.dart';
import 'package:sentimento_app/core/theme.dart';

/// Componente FlutterFlow para ações de contato (telefone e email)
///
/// Este componente fornece funcionalidades reutilizáveis para:
/// - Mostrar ações de telefone (ligar, SMS, WhatsApp, copiar)
/// - Mostrar ações de email (enviar email, copiar)
/// - Formatação de números brasileiros
/// - Interface consistente com o tema FlutterFlow
class FlutterFlowContactActions {
  /// Formata número de telefone brasileiro
  static String formatPhone(final String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    }
    return phone;
  }

  /// Valida se é um email válido
  static bool isValidEmail(final String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Abre WhatsApp com número e mensagem personalizada
  static Future<void> openWhatsApp(
    final BuildContext context,
    final String phone, {
    final String? customMessage,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message =
        customMessage ??
        'Olá! Sou ${AppConstants.enterpriseName} e gostaria de entrar em contato.';

    try {
      // Método 1: Usando WhatsAppUnilink
      final link = WhatsAppUnilink(
        phoneNumber: '+55$cleanPhone',
        text: message,
      );

      final uri = Uri.parse(link.toString());

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      // Método 2: Fallback para WhatsApp Web
      final webUri = Uri.parse(
        'https://web.whatsapp.com/send?phone=55$cleanPhone&text=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (context.mounted) {
        // Se nenhum método funcionar, mostrar erro
        _showErrorSnackBar(
          context,
          'WhatsApp não está instalado ou não pode ser aberto',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erro ao abrir WhatsApp: $e');
      }
    }
  }

  /// Faz uma ligação telefônica
  static Future<void> makePhoneCall(
    final BuildContext context,
    final String phone,
  ) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final uri = Uri.parse('tel:$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Não é possível fazer ligações neste dispositivo',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erro ao fazer ligação: $e');
      }
    }
  }

  /// Envia SMS
  static Future<void> sendSMS(
    final BuildContext context,
    final String phone, {
    final String? message,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final uri = message != null
          ? Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}')
          : Uri.parse('sms:$cleanPhone');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Não é possível enviar SMS neste dispositivo',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erro ao enviar SMS: $e');
      }
    }
  }

  /// Envia email
  static Future<void> sendEmail(
    final BuildContext context,
    final String email, {
    final String? subject,
    final String? body,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters(<String, String>{
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        }),
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Não é possível enviar email neste dispositivo',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erro ao enviar email: $e');
      }
    }
  }

  /// Copia texto para o clipboard
  static void copyToClipboard(
    final BuildContext context,
    final String text,
    final String type,
  ) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessSnackBar(context, '$type copiado: $text');
  }

  /// Mostra modal com ações para número de telefone
  static void showPhoneActions(
    final BuildContext context,
    final String phone, {
    final String? whatsappMessage,
    final String? smsMessage,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (final context) => _ContactActionsBottomSheet(
        title: formatPhone(phone),
        actions: [
          _ContactAction(
            icon: Icons.phone,
            title: 'Ligar',
            subtitle: 'Fazer uma ligação telefônica',
            color: Colors.green,
            onTap: () async {
              Navigator.pop(context);
              await makePhoneCall(context, phone);
            },
          ),
          _ContactAction(
            icon: Icons.message,
            title: 'SMS',
            subtitle: 'Enviar mensagem de texto',
            color: Colors.blue,
            onTap: () async {
              Navigator.pop(context);
              await sendSMS(context, phone, message: smsMessage);
            },
          ),
          _ContactAction(
            icon: Icons.chat,
            title: 'WhatsApp',
            subtitle: 'Abrir conversa no WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () async {
              Navigator.pop(context);
              await openWhatsApp(
                context,
                phone,
                customMessage: whatsappMessage,
              );
            },
          ),
          _ContactAction(
            icon: Icons.copy,
            title: 'Copiar',
            subtitle: 'Copiar número para área de transferência',
            color: FlutterFlowTheme.of(context).secondaryText,
            onTap: () {
              Navigator.pop(context);
              copyToClipboard(context, formatPhone(phone), 'Telefone');
            },
          ),
        ],
      ),
    );
  }

  /// Mostra modal com ações para email
  static void showEmailActions(
    final BuildContext context,
    final String email, {
    final String? subject,
    final String? body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (final context) => _ContactActionsBottomSheet(
        title: email,
        actions: [
          _ContactAction(
            icon: Icons.email,
            title: 'Enviar Email',
            subtitle: 'Abrir aplicativo de email',
            color: Colors.orange,
            onTap: () async {
              Navigator.pop(context);
              await sendEmail(context, email, subject: subject, body: body);
            },
          ),
          _ContactAction(
            icon: Icons.copy,
            title: 'Copiar',
            subtitle: 'Copiar email para área de transferência',
            color: FlutterFlowTheme.of(context).secondaryText,
            onTap: () {
              Navigator.pop(context);
              copyToClipboard(context, email, 'Email');
            },
          ),
        ],
      ),
    );
  }

  /// Cria um chip clicável para contato
  static Widget buildContactChip({
    required final BuildContext context,
    required final IconData icon,
    required final String text,
    required final Color color,
    final VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper para codificar parâmetros de query
  static String? _encodeQueryParameters(final Map<String, String> params) {
    return params.entries
        .map(
          (final e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  /// Mostra SnackBar de erro
  static void _showErrorSnackBar(
    final BuildContext context,
    final String message,
  ) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }

  /// Mostra SnackBar de sucesso
  static void _showSuccessSnackBar(
    final BuildContext context,
    final String message,
  ) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).success,
      ),
    );
  }
}

/// Classe para representar uma ação de contato
class _ContactAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

/// Widget do bottom sheet para ações de contato
class _ContactActionsBottomSheet extends StatelessWidget {
  final String title;
  final List<_ContactAction> actions;

  const _ContactActionsBottomSheet({
    required this.title,
    required this.actions,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Título
                Text(
                  title,
                  style: FlutterFlowTheme.of(
                    context,
                  ).headlineSmall.override(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Ações
                ...actions.map(
                  (final action) => _buildActionTile(context, action),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    final BuildContext context,
    final _ContactAction action,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(action.icon, color: action.color, size: 24),
      ),
      title: Text(
        action.title,
        style: FlutterFlowTheme.of(
          context,
        ).titleMedium.override(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        action.subtitle,
        style: FlutterFlowTheme.of(context).bodySmall,
      ),
      onTap: action.onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
