import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';

class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onSelectionChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onSelectionChanged,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final List<String> _availableTags = [
    'Trabalho',
    'Família',
    'Lazer',
    'Sono',
    'Saúde',
    'Exercício',
    'Comida',
    'Estudos',
    'Viagem',
    'Relacionamento',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTags.map((tag) {
        final isSelected = widget.selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (bool selected) {
            final newTags = List<String>.from(widget.selectedTags);
            if (selected) {
              newTags.add(tag);
            } else {
              newTags.remove(tag);
            }
            widget.onSelectionChanged(newTags);
          },
          backgroundColor: theme.primaryBackground,
          selectedColor: theme.primary.withOpacity(0.2),
          checkmarkColor: theme.primary,
          labelStyle: theme.bodyMedium.override(
            color: isSelected ? theme.primary : theme.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? theme.primary : theme.alternate,
            ),
          ),
          showCheckmark: false, // Cleaner look
          avatar: isSelected
              ? Icon(Icons.check, size: 16, color: theme.primary)
              : null,
        );
      }).toList(),
    );
  }
}
