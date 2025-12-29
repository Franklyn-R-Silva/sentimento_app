import 'package:flutter/material.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JournalModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  List<EntradasHumorRow> _entries = [];
  List<EntradasHumorRow> get entries => _entries;

  List<EntradasHumorRow> _filteredEntries = [];
  List<EntradasHumorRow> get filteredEntries => _filteredEntries;

  int? _filterMood;
  int? get filterMood => _filterMood;
  set filterMood(int? value) {
    _filterMood = value;
    _applyFilters();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    _applyFilters();
  }

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

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await EntradasHumorTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .order('criado_em', ascending: false)
            .limit(100),
      );

      _entries = response;
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
    } finally {
      isLoading = false;
    }
  }

  void _applyFilters() {
    _filteredEntries = _entries.where((entry) {
      // Filter by mood
      if (_filterMood != null && entry.nota != _filterMood) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final text = entry.notaTexto?.toLowerCase() ?? '';
        final tags = entry.tags?.join(' ').toLowerCase() ?? '';
        if (!text.contains(query) && !tags.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _filterMood = null;
    _searchQuery = '';
    _applyFilters();
  }
}
