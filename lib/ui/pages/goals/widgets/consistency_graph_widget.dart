// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// A GitHub-style consistency graph showing check-in history
class ConsistencyGraphWidget extends StatelessWidget {
  final List<DateTime> checkins;
  final Color color;
  final int daysToShow;

  const ConsistencyGraphWidget({
    super.key,
    required this.checkins,
    required this.color,
    this.daysToShow = 35, // 5 weeks
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: daysToShow - 1));

    // Create a set of check-in dates for O(1) lookup
    final checkinDates = checkins
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          'Consistência',
          style: theme.labelSmall.override(
            color: theme.secondaryText,
            fontWeight: FontWeight.w600,
          ),
          minFontSize: 8,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: Row(
            children: List.generate((daysToShow / 7).ceil(), (weekIndex) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (dayIndex) {
                    final dayOffset = weekIndex * 7 + dayIndex;
                    if (dayOffset >= daysToShow) {
                      return const SizedBox(width: 6, height: 6);
                    }

                    final date = startDate.add(Duration(days: dayOffset));
                    final dateOnly = DateTime(date.year, date.month, date.day);
                    final hasCheckin = checkinDates.contains(dateOnly);
                    final isToday =
                        dateOnly ==
                        DateTime(today.year, today.month, today.day);
                    final isFuture = date.isAfter(today);

                    return _buildDayCell(
                      theme,
                      hasCheckin: hasCheckin,
                      isToday: isToday,
                      isFuture: isFuture,
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    FlutterFlowTheme theme, {
    required bool hasCheckin,
    required bool isToday,
    required bool isFuture,
  }) {
    Color cellColor;

    if (isFuture) {
      cellColor = theme.alternate.withValues(alpha: 0.2);
    } else if (hasCheckin) {
      cellColor = color;
    } else {
      cellColor = theme.alternate.withValues(alpha: 0.3);
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(1),
        border: isToday ? Border.all(color: theme.primary, width: 1) : null,
      ),
    );
  }
}
