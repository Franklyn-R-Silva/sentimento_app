// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:sentimento_app/backend/services/data_refresh_service.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_card.dart';
import 'package:sentimento_app/ui/pages/journal/journal.model.dart';
import 'package:sentimento_app/ui/pages/journal/widgets/journal_entry_detail_sheet.dart';

class JournalCalendarView extends StatefulWidget {
  final JournalModel model;

  const JournalCalendarView({super.key, required this.model});

  @override
  State<JournalCalendarView> createState() => _JournalCalendarViewState();
}

class _JournalCalendarViewState extends State<JournalCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<EntradasHumorRow> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return widget.model.entriesByDate[normalizedDay] ?? [];
  }

  void _showEntryDetail(BuildContext context, EntradasHumorRow entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JournalEntryDetailSheet(
        entry: entry,
        onDelete: () async {
          try {
            await widget.model.deleteEntry(entry.id);
            if (context.mounted) Navigator.pop(context);
            DataRefreshService.instance.triggerRefresh();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
            }
          }
        },
        onUpdate: (newText) async {
          try {
            await widget.model.updateEntry(entry, newText);
            if (context.mounted) Navigator.pop(context);
            DataRefreshService.instance.triggerRefresh();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final List<EntradasHumorRow> events = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : [];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar<EntradasHumorRow>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: theme.error),
              defaultTextStyle: theme.bodyMedium,
              selectedDecoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              todayDecoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: theme.titleMedium.override(
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: theme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: theme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (events.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text('Registros do Dia', style: theme.labelLarge),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length}',
                    style: theme.bodySmall.override(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 48,
                        color: theme.secondaryText.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum registro neste dia',
                        style: theme.bodyMedium.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final entry = events[index];
                    return MoodCard(
                      entry: entry,
                      onTap: () => _showEntryDetail(context, entry),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
