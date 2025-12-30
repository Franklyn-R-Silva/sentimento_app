import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import '../fotos_anuais.model.dart';

class DateTimeSelectorWidget extends StatelessWidget {
  final FotosAnuaisModel model;

  const DateTimeSelectorWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GradientCard(
      moodLevel: model.moodLevel ?? 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data e Hora',
              style: theme.typography.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: model.selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(model.selectedDate),
                  );
                  if (time != null) {
                    model.selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(model.selectedDate),
                      style: theme.typography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
