// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

import 'package:sentimento_app/core/data/quotes.dart';

class DailyQuoteWidget extends StatefulWidget {
  const DailyQuoteWidget({super.key});

  @override
  State<DailyQuoteWidget> createState() => _DailyQuoteWidgetState();
}

class _DailyQuoteWidgetState extends State<DailyQuoteWidget> {
  late String _quote;
  late String _author;

  @override
  void initState() {
    super.initState();
    _pickRandomQuote();
  }

  void _pickRandomQuote() {
    final random = Random();
    final index = random.nextInt(kAllQuotes.length);
    setState(() {
      _quote = kAllQuotes[index]['text']!;
      _author = kAllQuotes[index]['author']!;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(Icons.format_quote_rounded, color: theme.primary, size: 24),
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
