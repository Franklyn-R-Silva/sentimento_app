// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/metas.dart';
import 'package:sentimento_app/core/model.dart';

class GoalsModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  List<MetasRow> _metas = [];
  List<MetasRow> get metas => _metas;

  List<MetasRow> get metasAtivas =>
      _metas.where((m) => m.ativo && !m.concluido).toList();
  List<MetasRow> get metasConcluidas =>
      _metas.where((m) => m.concluido).toList();

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
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      isLoading = false;
    }
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
    try {
      final newValue = meta.valorAtual + 1;
      final isCompleted = newValue >= meta.metaValor;

      await MetasTable().update(
        data: {'valor_atual': newValue, 'concluido': isCompleted},
        matchingRows: (q) => q.eq('id', meta.id),
      );

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
}
