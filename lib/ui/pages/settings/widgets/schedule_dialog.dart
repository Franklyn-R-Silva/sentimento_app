// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/services/notification_service.dart';

class ScheduleDialog extends StatefulWidget {
  final NotificationSchedule? schedule;

  const ScheduleDialog({super.key, this.schedule});

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.schedule != null
        ? TimeOfDay(
            hour: widget.schedule!.hour,
            minute: widget.schedule!.minute,
          )
        : const TimeOfDay(hour: 8, minute: 0);

    _selectedDays = widget.schedule != null
        ? List<int>.from(widget.schedule!.activeDays)
        : [1, 2, 3, 4, 5, 6, 7];
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AlertDialog(
      backgroundColor: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.schedule == null ? 'Novo Lembrete' : 'Editar Lembrete',
        style: theme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time Picker Button
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primary),
              ),
              child: Text(
                _selectedTime.format(context),
                style: theme.displaySmall.override(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Dias da Semana:', style: theme.bodyMedium),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final dayIndex = index + 1; // 1 = Mon
              final displayLabel = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'][index];
              final isSelected = _selectedDays.contains(dayIndex);

              return FilterChip(
                label: Text(displayLabel),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(dayIndex);
                    } else {
                      _selectedDays.remove(dayIndex);
                    }
                  });
                },
                selectedColor: theme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : theme.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: theme.primaryBackground,
                side: BorderSide(
                  color: isSelected ? theme.primary : theme.alternate,
                ),
                shape: const CircleBorder(),
                showCheckmark: false,
                padding: const EdgeInsets.all(4),
              );
            }),
          ),
        ],
      ),
      actions: [
        if (widget.schedule != null)
          TextButton(
            onPressed: () async {
              await NotificationService().deleteSchedule(widget.schedule!.id);
              if (mounted) {
                Navigator.pop(context, true); // true = refresh needed
              }
            },
            child: Text('Excluir', style: TextStyle(color: theme.error)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: theme.secondaryText)),
        ),
        TextButton(
          onPressed: () async {
            if (_selectedDays.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Selecione pelo menos um dia.',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: theme.error,
                ),
              );
              return;
            }

            final newSchedule = NotificationSchedule(
              id:
                  widget.schedule?.id ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              hour: _selectedTime.hour,
              minute: _selectedTime.minute,
              title: 'Lembrete do Sentimento',
              body: 'Hora de registrar como você está se sentindo!',
              activeDays: _selectedDays..sort(),
              isEnabled: true,
            );

            if (widget.schedule == null) {
              await NotificationService().addSchedule(newSchedule);
            } else {
              await NotificationService().updateSchedule(newSchedule);
            }

            if (mounted) Navigator.pop(context, true); // true = refresh needed
          },
          child: Text('Salvar', style: TextStyle(color: theme.primary)),
        ),
      ],
    );
  }
}
