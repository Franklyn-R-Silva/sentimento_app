// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/metas.dart';
import 'package:sentimento_app/backend/tables/metas_checkins.dart';
import 'package:sentimento_app/core/model.dart';

class GoalsModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  List<MetasRow> _metas = [];
  List<MetasRow> get metas => _metas;

  List<MetasRow> get metasAtivas =>
      _metas.where((m) => m.ativo && !m.concluido).toList();
  List<MetasRow> get metasConcluidas =>
      _metas.where((m) => m.concluido).toList();

  // Check-in history for consistency graph
  final Map<String, List<DateTime>> _checkinsHistory = {};
  Map<String, List<DateTime>> get checkinsHistory => _checkinsHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _showCelebration = false;
  bool get showCelebration => _showCelebration;

  String? _celebrationEmoji;
  String? get celebrationEmoji => _celebrationEmoji;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> loadMetas() async {
    isLoading = true;
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await MetasTable().queryRows(
        queryFn: (q) =>
            q.eq('user_id', userId).order('criado_em', ascending: false),
      );

      _metas = response;

      // Auto-reset logic for streak-based goals
      await _checkAndResetStreaks();

      // Load check-in history for active goals
      await _loadCheckinsHistory(userId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Checks if streaks need to be reset based on frequency
  Future<void> _checkAndResetStreaks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final meta in _metas) {
      if (meta.concluido || !meta.ativo || meta.ultimoCheckin == null) continue;

      final lastCheckin = meta.ultimoCheckin!;
      final daysSinceLastCheckin = today
          .difference(
            DateTime(lastCheckin.year, lastCheckin.month, lastCheckin.day),
          )
          .inDays;

      bool shouldReset = false;

      switch (meta.frequencia) {
        case 'diaria':
          // Reset if more than 1 day without check-in
          shouldReset = daysSinceLastCheckin > 1;
        case 'semanal':
          // Reset if more than 7 days without check-in
          shouldReset = daysSinceLastCheckin > 7;
        case 'mensal':
          // Reset if more than 30 days without check-in
          shouldReset = daysSinceLastCheckin > 30;
      }

      if (shouldReset && meta.valorAtual > 0) {
        await MetasTable().update(
          data: {'valor_atual': 0},
          matchingRows: (q) => q.eq('id', meta.id),
        );
        debugPrint('Reset streak for goal: ${meta.titulo}');
      }
    }
  }

  /// Loads check-in history for all active goals (last 90 days)
  Future<void> _loadCheckinsHistory(String userId) async {
    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));

      for (final meta in metasAtivas) {
        final checkins = await MetasCheckinsTable().queryRows(
          queryFn: (q) => q
              .eq('meta_id', meta.id)
              .gte('data_checkin', ninetyDaysAgo.toIso8601String())
              .order('data_checkin', ascending: true),
        );

        _checkinsHistory[meta.id] = checkins.map((c) => c.dataCheckin).toList();
      }
    } catch (e) {
      debugPrint('Error loading check-ins history: $e');
    }
  }

  /// Checks if the user already did a check-in today for this goal
  bool hasCheckedInToday(MetasRow meta) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (meta.ultimoCheckin == null) return false;

    final lastCheckin = meta.ultimoCheckin!;
    final lastCheckinDay = DateTime(
      lastCheckin.year,
      lastCheckin.month,
      lastCheckin.day,
    );

    return lastCheckinDay == todayOnly;
  }

  Future<void> addMeta({
    required String titulo,
    String? descricao,
    String categoria = 'geral',
    String tipo = 'streak',
    int metaValor = 7,
    String icone = '🎯',
    String cor = '#7C4DFF',
    String frequencia = 'diaria',
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await MetasTable().insert({
        'user_id': userId,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': categoria,
        'tipo': tipo,
        'meta_valor': metaValor,
        'valor_atual': 0,
        'icone': icone,
        'cor': cor,
        'frequencia': frequencia,
        'ativo': true,
        'concluido': false,
        'criado_em': DateTime.now().toIso8601String(),
      });
      await loadMetas();
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  Future<void> incrementProgress(MetasRow meta) async {
    // Check if already checked in today
    if (hasCheckedInToday(meta)) {
      debugPrint('Already checked in today for: ${meta.titulo}');
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      final newValue = meta.valorAtual + 1;
      final isCompleted = newValue >= meta.metaValor;

      // Update meta progress and ultimo_checkin
      await MetasTable().update(
        data: {
          'valor_atual': newValue,
          'concluido': isCompleted,
          'ultimo_checkin': now.toIso8601String(),
        },
        matchingRows: (q) => q.eq('id', meta.id),
      );

      // Record check-in in history
      await MetasCheckinsTable().insert({
        'meta_id': meta.id,
        'user_id': userId,
        'data_checkin': DateTime(
          now.year,
          now.month,
          now.day,
        ).toIso8601String(),
      });

      if (isCompleted) {
        _celebrationEmoji = meta.icone;
        _showCelebration = true;
        notifyListeners();

        // Auto hide celebration after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          _showCelebration = false;
          notifyListeners();
        });
      }

      await loadMetas();
    } catch (e) {
      debugPrint('Error incrementing progress: $e');
    }
  }

  Future<void> deleteMeta(String id) async {
    try {
      await MetasTable().delete(matchingRows: (q) => q.eq('id', id));
      _checkinsHistory.remove(id);
      await loadMetas();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }

  Future<void> toggleMeta(MetasRow meta) async {
    try {
      await MetasTable().update(
        data: {'ativo': !meta.ativo},
        matchingRows: (q) => q.eq('id', meta.id),
      );
      await loadMetas();
    } catch (e) {
      debugPrint('Error toggling goal: $e');
    }
  }

  void hideCelebration() {
    _showCelebration = false;
    notifyListeners();
  }

  /// Get current streak count (consecutive days)
  int getCurrentStreak(MetasRow meta) {
    final history = _checkinsHistory[meta.id] ?? [];
    if (history.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);

    for (var i = history.length - 1; i >= 0; i--) {
      final checkinDate = history[i];
      final checkinDay = DateTime(
        checkinDate.year,
        checkinDate.month,
        checkinDate.day,
      );

      if (checkinDay == checkDate ||
          checkinDay == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = checkinDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
