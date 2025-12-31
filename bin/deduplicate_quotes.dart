import 'dart:io';

void main() async {
  final file = File('lib/core/data/quotes.dart');
  if (!await file.exists()) {
    print('File not found: ${file.path}');
    return;
  }

  final content = await file.readAsString();

  // Extract content between brackets
  final startBracket = content.indexOf('[');
  final endBracket = content.lastIndexOf(']');

  if (startBracket == -1 || endBracket == -1) {
    print('Could not find list brackets in file');
    return;
  }

  // Parse the raw manually because it's not valid JSON (no quotes around keys, comments etc)
  // We will simply regex out the text and author pairs
  final RegExp quoteRegex = RegExp(
    r"\{\s*'text':\s*'''?(.*?)'''?,\s*'author':\s*'(.*?)',?\s*\},",
    multiLine: true,
    dotAll: true,
  );
  final RegExp singleLineQuoteRegex = RegExp(
    r"\{\s*'text':\s*'(.*?)',\s*'author':\s*'(.*?)',?\s*\},",
  );

  // Actually, a safer approach since I'm an AI agent and I can see the file format is simple:
  // Convert the file content to a list of objects, dedupe, and rewrite.
  // But since I can't import the package code easily in this script context without pub get complications
  // I will write a script that parses the specific format of this file.

  final lines = await file.readAsLines();
  List<String> outputLines = [];
  Set<String> seenQuotes = {};

  bool insideList = false;
  List<String> currentBlock = [];
  String currentText = '';

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line.trim().startsWith(
      'final List<Map<String, String>> kAllQuotes = [',
    )) {
      outputLines.add(line);
      insideList = true;
      continue;
    }

    if (line.trim() == '];') {
      if (currentBlock.isNotEmpty) {
        _processBlock(currentBlock, seenQuotes, outputLines);
      }
      outputLines.add(line);
      insideList = false;
      continue;
    }

    if (!insideList) {
      if (line.trim().isNotEmpty) outputLines.add(line);
      continue;
    }

    // We are inside the list. Gather blocks.
    if (line.trim() == '{' || line.trim().startsWith('{')) {
      currentBlock = [line];
    } else if (line.trim() == '},' || line.trim() == '}') {
      currentBlock.add(line);
      _processBlock(currentBlock, seenQuotes, outputLines);
      currentBlock = [];
    } else {
      currentBlock.add(line);
    }
  }

  await file.writeAsString(outputLines.join('\n'));
  print('Deduplication complete.');
}

void _processBlock(
  List<String> block,
  Set<String> seenQuotes,
  List<String> outputLines,
) {
  final fullBlock = block.join('\n');

  // Extract text
  String text = '';
  // Simple extraction strategies
  if (fullBlock.contains("'text':")) {
    final parts = fullBlock.split("'text':");
    if (parts.length > 1) {
      String remaining = parts[1].trim();
      // Check for multiline string
      if (remaining.startsWith("'''")) {
        // Handle multiline
        final end = remaining.indexOf("'''", 3);
        if (end != -1) text = remaining.substring(3, end);
      } else if (remaining.startsWith("'")) {
        // Handle single line
        final end = remaining.indexOf("',");
        if (end != -1) text = remaining.substring(1, end);
      }
    }
  }

  // Very naive normalization for simple dedup
  final normalizedText = text
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  if (normalizedText.isNotEmpty) {
    if (seenQuotes.contains(normalizedText)) {
      print('Duplicate found and removed: $normalizedText');
      return;
    }
    seenQuotes.add(normalizedText);
  }

  outputLines.addAll(block);
}
