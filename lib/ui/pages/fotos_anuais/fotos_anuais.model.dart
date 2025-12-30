import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/fotos_anuais.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class FotosAnuaisModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();
  final fraseController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  int? _moodLevel;
  int? get moodLevel => _moodLevel;
  set moodLevel(int? value) {
    _moodLevel = value;
    notifyListeners();
  }

  Uint8List? _selectedImageBytes;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  String? _imageName;

  bool _isUploading = false;
  bool get isUploading => _isUploading;
  set isUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    fraseController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImageBytes = await image.readAsBytes();
        _imageName = image.name;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<bool> savePhoto(BuildContext context) async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma foto primeiro.'),
        ),
      );
      return false;
    }

    isUploading = true;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) throw Exception('Usuário não autenticado.');

      // 1. Upload to Storage
      final fileExtension = _imageName?.split('.').last ?? 'jpg';
      final fileName =
          '${userId}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = 'fotos_anuais/$fileName';

      await supabase.storage
          .from('fotos_anuais')
          .uploadBinary(
            fileName,
            _selectedImageBytes!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = supabase.storage
          .from('fotos_anuais')
          .getPublicUrl(fileName);

      // 2. Save to Database
      await FotosAnuaisTable().insert({
        'user_id': userId,
        'image_url': imageUrl,
        'frase': fraseController.text.isNotEmpty ? fraseController.text : null,
        'mood_level': _moodLevel,
        'data_foto': _selectedDate.toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto salva com sucesso!')));

      // Clear selection
      _selectedImageBytes = null;
      _imageName = null;
      _moodLevel = null;
      fraseController.clear();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar foto: $e')));
      return false;
    } finally {
      isUploading = false;
    }
  }
}
