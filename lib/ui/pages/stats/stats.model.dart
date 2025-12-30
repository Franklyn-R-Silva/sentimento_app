// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/model.dart';

class StatsModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  double _averageMood = 0;
  double get averageMood => _averageMood;

  int _totalEntries = 0;
  int get totalEntries => _totalEntries;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int _longestStreak = 0;
  int get longestStreak => _longestStreak;

  Map<int, int> _moodDistribution = {};
  Map<int, int> get moodDistribution => _moodDistribution;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> loadStats() async {
    isLoading = true;
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        isLoading = false;
        return;
      }

      // Fetch all entries for the user
      final entries = await EntradasHumorTable().queryRows(
        queryFn: (q) =>
            q.eq('user_id', userId).order('criado_em', ascending: true),
      );

      if (entries.isEmpty) {
        _averageMood = 0;
        _totalEntries = 0;
        _currentStreak = 0;
        _longestStreak = 0;
        _moodDistribution = {};
        notifyListeners();
        return;
      }

      // Calculate total entries
      _totalEntries = entries.length;

      // Calculate average mood
      if (entries.isNotEmpty) {
        _averageMood =
            entries.map((e) => e.nota).reduce((a, b) => a + b) / entries.length;
      }

      // Calculate mood distribution
      _moodDistribution = {};
      for (final entry in entries) {
        final mood = entry.nota;
        _moodDistribution[mood] = (_moodDistribution[mood] ?? 0) + 1;
      }

      // Calculate streaks
      final streaks = calculateStreaks(entries);
      _currentStreak = streaks['current'] ?? 0;
      _longestStreak = streaks['longest'] ?? 0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      isLoading = false;
    }
  }

  @visibleForTesting
  Map<String, int> calculateStreaks(List<EntradasHumorRow> entries) {
    if (entries.isEmpty) return {'current': 0, 'longest': 0};

    // Get unique dates (only date part, no time)
    final dates =
        entries
            .map(
              (e) =>
                  DateTime(e.criadoEm.year, e.criadoEm.month, e.criadoEm.day),
            )
            .toSet()
            .toList()
          ..sort();

    if (dates.isEmpty) return {'current': 0, 'longest': 0};

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    // Check if current streak is still active (last entry was today or yesterday)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastEntryDate = dates.last;
    final daysSinceLastEntry = todayDate.difference(lastEntryDate).inDays;

    if (daysSinceLastEntry > 1) {
      // Streak is broken
      currentStreak = 0;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }
}
