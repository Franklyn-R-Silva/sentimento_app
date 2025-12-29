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

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
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
            .order('created_at', ascending: false)
            .limit(10),
      );
      recentEntries = recentResponse;

      // Fetch last 7 days for weekly chart
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final weeklyResponse = await EntradasHumorTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .gte('created_at', sevenDaysAgo.toIso8601String())
            .order('created_at', ascending: true),
      );
      weeklyEntries = weeklyResponse;

      // Fetch current year for annual chart
      final startOfYear = DateTime(now.year, 1, 1);
      final annualResponse = await EntradasHumorTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .gte('created_at', startOfYear.toIso8601String())
            .order('created_at', ascending: true),
      );
      annualEntries = annualResponse;

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
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await EntradasHumorTable().insert({
        'user_id': userId,
        'nota': nota,
        'nota_texto': texto,
        'tags': tags,
        'created_at': DateTime.now().toIso8601String(),
      });
      await loadData(); // Refresh and notify listeners
    } catch (e) {
      debugPrint('Error adding entry: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }
}
