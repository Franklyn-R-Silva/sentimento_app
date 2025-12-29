import 'package:flutter/material.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  /// State fields for stateful widgets in this page.
  final unfocusNode = FocusNode();

  List<EntradasHumorRow> recentEntries = [];
  List<EntradasHumorRow> weeklyEntries = [];
  List<EntradasHumorRow> annualEntries = [];

  int _longestStreak = 0;
  int get longestStreak => _longestStreak;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isAddingEntry = false;
  bool get isAddingEntry => _isAddingEntry;
  set isAddingEntry(bool value) {
    _isAddingEntry = value;
    notifyListeners();
  }

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  /// Action blocks are added here.

  Future<void> loadData() async {
    isLoading = true;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Fetch Recent (Last 10)
      final recentResponse = await EntradasHumorTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .order('criado_em', ascending: false)
            .limit(10),
      );
      recentEntries = recentResponse;

      // Fetch last 7 days for weekly chart
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final weeklyResponse = await EntradasHumorTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .gte('criado_em', sevenDaysAgo.toIso8601String())
            .order('criado_em', ascending: true),
      );
      weeklyEntries = weeklyResponse;

      // Fetch current year for annual chart
      final startOfYear = DateTime(now.year, 1, 1);
      final annualResponse = await EntradasHumorTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .gte('criado_em', startOfYear.toIso8601String())
            .order('criado_em', ascending: true),
      );
      annualEntries = annualResponse;

      // Calculate streaks
      _longestStreak = _calculateLongestStreak(annualEntries);
      _currentStreak = _calculateCurrentStreak(recentEntries);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> addEntry(
    BuildContext context,
    int nota,
    String? texto,
    List<String> tags,
  ) async {
    if (isAddingEntry) return;
    isAddingEntry = true;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      isAddingEntry = false;
      return;
    }

    try {
      await EntradasHumorTable().insert({
        'user_id': userId,
        'nota': nota,
        'nota_texto': texto,
        'tags': tags,
        'criado_em': DateTime.now().toIso8601String(),
      });
      await loadData(); // Refresh and notify listeners
    } catch (e) {
      debugPrint('Error adding entry: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      isAddingEntry = false;
    }
  }

  /// Calculates the longest streak of consecutive days with entries
  int _calculateLongestStreak(List<EntradasHumorRow> entries) {
    if (entries.isEmpty) return 0;

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

    if (dates.isEmpty) return 0;

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

    return longestStreak;
  }

  int _calculateCurrentStreak(List<EntradasHumorRow> entries) {
    if (entries.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var entry in entries) {
      final entryDate = DateTime(
        entry.criadoEm.year,
        entry.criadoEm.month,
        entry.criadoEm.day,
      );

      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        if (entryDate == todayDate ||
            entryDate == todayDate.subtract(const Duration(days: 1))) {
          streak = 1;
          lastDate = entryDate;
        } else {
          break;
        }
      } else {
        final diff = lastDate.difference(entryDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = entryDate;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return streak;
  }
}
