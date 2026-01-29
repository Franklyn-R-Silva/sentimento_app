// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/services/toast_service.dart';

class GymRegisterModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final stretchingSeriesController = TextEditingController();
  final stretchingQtyController = TextEditingController();
  final exerciseSeriesController = TextEditingController();
  final exerciseQtyController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedDay;
  final List<String> daysOfWeek = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  List<XFile> _selectedImages = [];
  List<XFile> get selectedImages => _selectedImages;

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
    nameController.dispose();
    stretchingSeriesController.dispose();
    stretchingQtyController.dispose();
    exerciseSeriesController.dispose();
    exerciseQtyController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 800,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      _selectedImages.addAll(images);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<List<String>> _uploadImages(String userId) async {
    if (_selectedImages.isEmpty) return [];

    List<String> uploadedUrls = [];
    final supabase = Supabase.instance.client;

    for (var image in _selectedImages) {
      try {
        final fileBytes = await image.readAsBytes();
        final fileExt = image.path.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final path = '$userId/$fileName';

        await supabase.storage
            .from('gym_photos')
            .uploadBinary(
              path,
              fileBytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );

        final publicUrl = await supabase.storage
            .from('gym_photos')
            .createSignedUrl(path, 315360000); // ~10 years

        uploadedUrls.add(publicUrl);
      } catch (e) {
        Logger().e('Error uploading image ${image.name}: $e');
        // Continue uploading others or throw?
        // Let's rethrow to stop process if one fails, or just log.
        // For robustness, maybe we should stop and tell user.
        throw Exception('Falha ao upar imagem ${image.name}');
      }
    }
    return uploadedUrls;
  }

  Future<bool> saveExercise(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedDay == null) {
      ToastService.showWarning('Selecione o dia da semana');
      return false;
    }

    isLoading = true;
    final logger = Logger();

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ToastService.showError('Usuário não autenticado');
        return false;
      }

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        try {
          imageUrls = await _uploadImages(userId);
        } catch (e) {
          ToastService.showError('Erro ao salvar fotos. Verifique conexão.');
          isLoading = false;
          return false;
        }
      }

      // Convert list of URLs to JSON string [url1, url2] or keep as single string if only 1 (backward compatibility?)
      // We decided to store as JSON list style string if multiple.
      // But let's verify how `GymExercisesRow` reads it.
      // In `GymExerciseCard` I implemented a check: if starts with `[` it parses list.
      // So I should save as `['url1', 'url2']` formatted string.

      String? machinePhotoUrl;
      if (imageUrls.isNotEmpty) {
        if (imageUrls.length == 1) {
          machinePhotoUrl = imageUrls.first;
        } else {
          machinePhotoUrl = imageUrls
              .toString(); // Dart's default list to string is [a, b]
        }
      }

      await GymExercisesTable().insert({
        'user_id': userId,
        'name': nameController.text,
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        'stretching_series': int.tryParse(stretchingSeriesController.text),
        'stretching_qty': int.tryParse(stretchingQtyController.text),
        'exercise_series': int.tryParse(exerciseSeriesController.text),
        'exercise_qty': int.tryParse(exerciseQtyController.text),
        'machine_photo_url': machinePhotoUrl,
        'day_of_week': selectedDay,
        'created_at': DateTime.now().toIso8601String(),
      });

      ToastService.showSuccess('Exercício salvo com sucesso!');
      return true;
    } catch (e) {
      logger.e('Error saving exercise: $e');
      ToastService.showError('Erro ao salvar exercício');
      return false;
    } finally {
      isLoading = false;
    }
  }
}
