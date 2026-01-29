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
  final stretchingNameController = TextEditingController();
  final stretchingSeriesController = TextEditingController();
  final stretchingQtyController = TextEditingController();
  final stretchingTimeController = TextEditingController();

  // New Exercise Controllers
  final setsController = TextEditingController(); // Replaces exerciseSeries
  final repsController = TextEditingController(); // Replaces exerciseQty
  final weightController = TextEditingController();
  final restTimeController = TextEditingController();

  // Legacy controllers kept if needed for migration, otherwise we can remove them or alias them
  // keeping purely for not breaking existing references immediately if any, but plan replaces them
  // actually I will remove them and use sets/reps instead as per requirement 'Implementar'
  // but existing UI uses them so I should be careful. I will deprecate them in UI next step.
  // For now let's add the new ones.

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

  String? selectedCategory;
  final List<String> categories = ['Musculação', 'Cardio', 'Mobilidade'];

  String? selectedMuscleGroup;
  final List<String> muscleGroups = [
    'Peito',
    'Costas',
    'Pernas',
    'Ombros',
    'Bíceps',
    'Tríceps',
    'Abdômen',
    'Outros',
  ];

  final List<XFile> _selectedImages = [];
  List<XFile> get selectedImages => _selectedImages;

  final List<XFile> _selectedStretchingImages = []; // New
  List<XFile> get selectedStretchingImages => _selectedStretchingImages;

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
    stretchingNameController.dispose();
    stretchingSeriesController.dispose();
    stretchingQtyController.dispose();
    stretchingTimeController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    restTimeController.dispose();
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

  // New methods for stretching images
  Future<void> pickStretchingImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 800,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      _selectedStretchingImages.addAll(images);
      notifyListeners();
    }
  }

  void removeStretchingImage(int index) {
    if (index >= 0 && index < _selectedStretchingImages.length) {
      _selectedStretchingImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<List<String>> _uploadImages(String userId, List<XFile> images) async {
    if (images.isEmpty) return [];

    final List<String> uploadedUrls = [];
    final supabase = Supabase.instance.client;

    for (var image in images) {
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
          imageUrls = await _uploadImages(userId, _selectedImages);
        } catch (e) {
          ToastService.showError('Erro ao salvar fotos. Verifique conexão.');
          isLoading = false;
          return false;
        }
      }

      // Upload stretching images
      List<String> stretchingImageUrls = [];
      if (_selectedStretchingImages.isNotEmpty) {
        try {
          stretchingImageUrls = await _uploadImages(
            userId,
            _selectedStretchingImages,
          );
        } catch (e) {
          ToastService.showError('Erro ao salvar fotos do alongamento.');
          isLoading = false;
          return false;
        }
      }

      String? machinePhotoUrl;
      if (imageUrls.isNotEmpty) {
        if (imageUrls.length == 1) {
          machinePhotoUrl = imageUrls.first;
        } else {
          machinePhotoUrl = imageUrls.toString();
        }
      }

      String? stretchingPhotoUrl;
      if (stretchingImageUrls.isNotEmpty) {
        if (stretchingImageUrls.length == 1) {
          stretchingPhotoUrl = stretchingImageUrls.first;
        } else {
          stretchingPhotoUrl = stretchingImageUrls.toString();
        }
      }

      await GymExercisesTable().insert({
        'user_id': userId,
        'name': nameController.text,
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        'category': selectedCategory,
        'muscle_group': selectedMuscleGroup,
        'sets': int.tryParse(setsController.text),
        'reps': repsController.text,
        'weight': double.tryParse(weightController.text.replaceAll(',', '.')),
        'rest_time': int.tryParse(restTimeController.text),
        'stretching_name': stretchingNameController.text.isNotEmpty
            ? stretchingNameController.text
            : null,
        'stretching_series': int.tryParse(stretchingSeriesController.text),
        'stretching_qty': int.tryParse(stretchingQtyController.text),
        'stretching_time': stretchingTimeController.text.isNotEmpty
            ? stretchingTimeController.text
            : null,
        'machine_photo_url': machinePhotoUrl,
        'stretching_photo_url': stretchingPhotoUrl,
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
