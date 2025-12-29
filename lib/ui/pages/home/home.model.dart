import 'package:flutter/material.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeModel extends FlutterFlowModel<Widget> {
  /// State fields for stateful widgets in this page.
  final unfocusNode = FocusNode();

  List<EntradasHumorRow> recentEntries = [];
  List<EntradasHumorRow> weeklyEntries = [];
  List<EntradasHumorRow> annualEntries = [];

  bool isLoading = false;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  Future<void> loadData() async {
    isLoading = true;
    // Notify if extending ChangeNotifier, or use setState in page
    // For now we just fetch, page will handle state update via FutureBuilder or similar,
    // but better if we store state here and page observes.
    // FlutterFlow models usually store state.

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
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await EntradasHumorTable().insert({
        'user_id': userId,
        'nota': nota,
        'nota_texto': texto,
        'tags': tags,
        'criado_em': DateTime.now().toIso8601String(),
      });
      await loadData(); // Refresh
    } catch (e) {
      debugPrint('Error adding entry: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }
}
