// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class DailyQuoteWidget extends StatefulWidget {
  const DailyQuoteWidget({super.key});

  @override
  State<DailyQuoteWidget> createState() => _DailyQuoteWidgetState();
}

class _DailyQuoteWidgetState extends State<DailyQuoteWidget> {
  late String _quote;
  late String _author;

  final List<Map<String, String>> _quotes = [
    {
      'text': 'A felicidade não é algo pronto. Ela vem de suas próprias ações.',
      'author': 'Dalai Lama',
    },
    {
      'text': 'O único modo de fazer um ótimo trabalho é amar o que você faz.',
      'author': 'Steve Jobs',
    },
    {
      'text':
          'A vida é 10% o que acontece com você e 90% como você reage a isso.',
      'author': 'Charles R. Swindoll',
    },
    {
      'text': 'Acredite que você pode, e você já está no meio do caminho.',
      'author': 'Theodore Roosevelt',
    },
    {
      'text': 'Não conte os dias, faça os dias contarem.',
      'author': 'Muhammad Ali',
    },
    {
      'text': 'O sucesso é a soma de pequenos esforços repetidos dia após dia.',
      'author': 'Robert Collier',
    },
    {
      'text': 'Tudo o que você sempre quis está do outro lado do medo.',
      'author': 'George Addair',
    },
    {
      'text': 'A melhor maneira de prever o futuro é criá-lo.',
      'author': 'Peter Drucker',
    },
    {
      'text': 'Não espere. O tempo nunca será o ideal.',
      'author': 'Napoleon Hill',
    },
    {
      'text':
          'Você é mais corajoso do que acredita, mais forte do que parece e mais inteligente do que pensa.',
      'author': 'A.A. Milne',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomQuote();
  }

  void _pickRandomQuote() {
    final random = Random();
    final index = random.nextInt(_quotes.length);
    setState(() {
      _quote = _quotes[index]['text']!;
      _author = _quotes[index]['author']!;
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
