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
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/data/quotes.dart';

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
    Logger().v('DailyQuoteWidget: build called');
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: theme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Frase do Dia',
                    style: theme.labelMedium.override(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: theme.secondaryText,
                    ),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copiar',
                  ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 20,
                      color: theme.success,
                    ),
                    onPressed: _shareToWhatsApp,
                    tooltip: 'WhatsApp',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            '"$_quote"',
            style: theme.bodyMedium.override(
              fontStyle: FontStyle.italic,
              color: theme.primaryText,
            ),
            minFontSize: 12,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '- $_author',
              style: theme.labelSmall.override(color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
