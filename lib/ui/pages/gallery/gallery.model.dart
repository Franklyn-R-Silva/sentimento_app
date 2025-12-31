// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/model.dart';

enum GalleryFilter { all, thisMonth, thisYear }

class GalleryModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  List<FotosAnuaisRow> _photos = [];
  List<FotosAnuaisRow> get photos => _filteredPhotos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GalleryFilter _filter = GalleryFilter.all;
  GalleryFilter get filter => _filter;
  set filter(GalleryFilter value) {
    _filter = value;
    notifyListeners();
  }

  int? _moodFilter;
  int? get moodFilter => _moodFilter;
  set moodFilter(int? value) {
    _moodFilter = value;
    notifyListeners();
  }

  List<FotosAnuaisRow> get _filteredPhotos {
    var result = _photos;

    // Apply date filter
    final now = DateTime.now();
    switch (_filter) {
      case GalleryFilter.thisMonth:
        result = result.where((p) {
          return p.dataFoto.year == now.year && p.dataFoto.month == now.month;
        }).toList();
      case GalleryFilter.thisYear:
        result = result.where((p) => p.dataFoto.year == now.year).toList();
      case GalleryFilter.all:
        break;
    }

    // Apply mood filter
    if (_moodFilter != null) {
      result = result.where((p) => p.moodLevel == _moodFilter).toList();
    }

    return result;
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> loadPhotos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuário não autenticado.');
      }

      final data = await FotosAnuaisTable().queryRows(
        queryFn: (q) =>
            q.eq('user_id', userId).order('data_foto', ascending: false),
      );

      _photos = data;
    } catch (e) {
      debugPrint('Error loading photos: $e');
      _photos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePhoto(BuildContext context, FotosAnuaisRow photo) async {
    try {
      final supabase = Supabase.instance.client;

      // Extract storage path from URL
      final url = photo.imageUrl;
      final pathMatch = RegExp(r'fotos_anuais/(.+)$').firstMatch(url);

      if (pathMatch != null) {
        final storagePath = pathMatch.group(1)!;
        await supabase.storage.from('fotos_anuais').remove([storagePath]);
      }

      // Delete from database
      await FotosAnuaisTable().delete(
        matchingRows: (q) => q.eq('id', photo.id),
      );

      // Remove from local list
      _photos.removeWhere((p) => p.id == photo.id);
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto excluída com sucesso!')),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir foto: $e')));
      }
      return false;
    }
  }

  void clearFilters() {
    _filter = GalleryFilter.all;
    _moodFilter = null;
    notifyListeners();
  }
}
