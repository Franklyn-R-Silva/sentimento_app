// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

// Project imports:
import 'package:sentimento_app/core/data/quotes.dart';
import 'package:sentimento_app/core/theme.dart';

class DailyQuoteWidget extends StatefulWidget {
  const DailyQuoteWidget({super.key});

  @override
  State<DailyQuoteWidget> createState() => _DailyQuoteWidgetState();
}

class _DailyQuoteWidgetState extends State<DailyQuoteWidget>
    with WidgetsBindingObserver {
  late String _quote;
  late String _author;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pickQuoteByTime(updateState: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pickQuoteByTime(updateState: true);
    }
  }

  void _pickQuoteByTime({required bool updateState}) {
    if (kAllQuotes.isEmpty) {
      _quote = 'Sem frases hoje.';
      _author = '';
      if (updateState && mounted) setState(() {});
      return;
    }

    final now = DateTime.now();
    // 0: Morning (00-11), 1: Afternoon (12-17), 2: Evening (18-23)
    final int period = now.hour < 12
        ? 0
        : now.hour < 18
        ? 1
        : 2;

    // Calculate day of year
    final int dayOfYear = int.parse(DateFormat('D').format(now));

    // Create a stable index based on day and period
    final int seed = (dayOfYear * 3) + period;
    final int index = seed % kAllQuotes.length;

    final String newQuote = kAllQuotes[index]['text'] ?? 'Frase indisponível';
    final String newAuthor = kAllQuotes[index]['author'] ?? 'Desconhecido';

    if (updateState && mounted) {
      setState(() {
        _quote = newQuote;
        _author = newAuthor;
      });
    } else {
      _quote = newQuote;
      _author = newAuthor;
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: '"$_quote" - $_author'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Frase copiada!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareToWhatsApp() async {
    final text = '"$_quote" - $_author\n\nEnviado do Sentimento App';

    try {
      final link = WhatsAppUnilink(text: text);
      await launchUrl(
        Uri.parse(link.toString()),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Fallback to share_plus if WhatsApp fails or not installed logic needs it
      await Share.share(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger().t('DailyQuoteWidget: build called');
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.secondaryBackground,
            theme.secondaryBackground.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 140,
              color: theme.primary.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: theme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Frase do Dia',
                            style: theme.labelSmall.override(
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          theme,
                          Icons.copy_rounded,
                          _copyToClipboard,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          theme,
                          FontAwesomeIcons.whatsapp,
                          _shareToWhatsApp,
                          isFa: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AutoSizeText(
                  '"$_quote"',
                  style: theme.titleMedium.override(
                    fontStyle: FontStyle.italic,
                    color: theme.primaryText,
                    lineHeight: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                  minFontSize: 16,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— $_author',
                    style: theme.labelMedium.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    FlutterFlowTheme theme,
    IconData icon,
    VoidCallback onPressed, {
    bool isFa = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate.withValues(alpha: 0.5)),
          ),
          child: isFa
              ? FaIcon(icon, size: 16, color: theme.secondaryText)
              : Icon(icon, size: 18, color: theme.secondaryText),
        ),
      ),
    );
  }
}
