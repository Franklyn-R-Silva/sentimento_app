// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/backend/tables/gym_workouts.dart';
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
  final timeController = TextEditingController(); // Added

  // New Exercise Controllers
  final setsController = TextEditingController(); // Replaces exerciseSeries
  final repsController = TextEditingController(); // Replaces exerciseQty
  final weightController = TextEditingController();
  final restTimeController = TextEditingController();

  final descriptionController = TextEditingController();

  // Workouts
  List<GymWorkoutsRow> workouts = [];
  String? selectedWorkoutId;

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

  final List<String> _existingMachineImages = [];
  List<String> get existingMachineImages => _existingMachineImages;

  final List<XFile> _selectedStretchingImages = []; // New
  List<XFile> get selectedStretchingImages => _selectedStretchingImages;

  final List<String> _existingStretchingImages = [];
  List<String> get existingStretchingImages => _existingStretchingImages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void initState(BuildContext context) {
    // Auto-fill with today's day of week
    if (selectedDay == null) {
      selectedDay = _getCurrentDayOfWeek();
    }
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await GymWorkoutsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).order('name'),
      );
      workouts = response;
      notifyListeners();
    } catch (e) {
      Logger().e('Error loading workouts: $e');
    }
  }

  String _getCurrentDayOfWeek() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'Segunda';
      case DateTime.tuesday:
        return 'Terça';
      case DateTime.wednesday:
        return 'Quarta';
      case DateTime.thursday:
        return 'Quinta';
      case DateTime.friday:
        return 'Sexta';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Segunda';
    }
  }

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
    timeController.dispose(); // Added
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

  void removeExistingMachineImage(int index) {
    if (index >= 0 && index < _existingMachineImages.length) {
      _existingMachineImages.removeAt(index);
      notifyListeners();
    }
  }

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

  void removeExistingStretchingImage(int index) {
    if (index >= 0 && index < _existingStretchingImages.length) {
      _existingStretchingImages.removeAt(index);
      notifyListeners();
    }
  }

  // Restore _uploadImages method locally
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
            .createSignedUrl(path, 315360000); // 10 years

        uploadedUrls.add(publicUrl);
      } catch (e) {
        Logger().e('Error uploading image ${image.name}: $e');
        // We throw so the caller knows something failed
        throw Exception('Falha ao upar imagem ${image.name}');
      }
    }
    return uploadedUrls;
  }

  // Edit Mode
  String? exerciseId;
  GymExercisesRow? editingExercise;

  void initFromExercise(
    GymExercisesRow exercise, {
    bool isDuplication = false,
  }) {
    exerciseId = isDuplication ? null : exercise.id;
    // If duplication, we don't set editingExercise (or set to null) to avoid updates?
    // Actually editingExercise is used maybe for reference?
    // If exerciseId is null, saveExercise treats as INSERT.
    // So just clearing exerciseId is enough.
    editingExercise = isDuplication ? null : exercise;

    nameController.text = exercise.name;
    descriptionController.text = exercise.description ?? '';
    selectedCategory = exercise.category;
    selectedMuscleGroup = exercise.muscleGroup;
    setsController.text = exercise.sets?.toString() ?? '';
    repsController.text = exercise.reps ?? '';
    weightController.text = exercise.weight?.toString() ?? '';
    restTimeController.text = exercise.restTime?.toString() ?? '';
    timeController.text = exercise.exerciseTime ?? ''; // Added
    selectedDay = exercise.dayOfWeek;
    selectedWorkoutId = exercise.workoutId;

    // Stretching fields
    stretchingNameController.text = exercise.stretchingName ?? '';
    stretchingSeriesController.text =
        exercise.stretchingSeries?.toString() ?? '';
    stretchingQtyController.text = exercise.stretchingQty?.toString() ?? '';
    stretchingTimeController.text = exercise.stretchingTime ?? '';

    // Parse images
    final machineUrl = exercise.machinePhotoUrl;
    if (machineUrl != null && machineUrl.isNotEmpty) {
      _existingMachineImages.clear();
      if (machineUrl.trim().startsWith('[')) {
        try {
          final clean = machineUrl.trim().substring(
            1,
            machineUrl.trim().length - 1,
          );
          if (clean.isNotEmpty) {
            _existingMachineImages.addAll(
              clean
                  .split(',')
                  .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
                  .toList(),
            );
          }
        } catch (_) {}
      } else {
        _existingMachineImages.add(machineUrl);
      }
    }

    // Parse stretching images
    final stretchingUrl = exercise.stretchingPhotoUrl;
    if (stretchingUrl != null && stretchingUrl.isNotEmpty) {
      _existingStretchingImages.clear();
      if (stretchingUrl.trim().startsWith('[')) {
        try {
          final clean = stretchingUrl.trim().substring(
            1,
            stretchingUrl.trim().length - 1,
          );
          if (clean.isNotEmpty) {
            _existingStretchingImages.addAll(
              clean
                  .split(',')
                  .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
                  .toList(),
            );
          }
        } catch (_) {}
      } else {
        _existingStretchingImages.add(stretchingUrl);
      }
    }

    notifyListeners();
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

      // Logic for URLs:
      // COMBINE existing + new
      String? finalMachineUrl;
      final List<String> allMachineUrls = [
        ..._existingMachineImages,
        ...imageUrls,
      ];
      if (allMachineUrls.isNotEmpty) {
        if (allMachineUrls.length == 1) {
          finalMachineUrl = allMachineUrls.first;
        } else {
          finalMachineUrl = allMachineUrls.toString();
        }
      }

      String? finalStretchingUrl;
      final List<String> allStretchingUrls = [
        ..._existingStretchingImages,
        ...stretchingImageUrls,
      ];
      if (allStretchingUrls.isNotEmpty) {
        if (allStretchingUrls.length == 1) {
          finalStretchingUrl = allStretchingUrls.first;
        } else {
          finalStretchingUrl = allStretchingUrls.toString();
        }
      }

      final data = {
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
        'exercise_time': timeController.text.isNotEmpty
            ? timeController.text
            : null, // Added
        'stretching_name': stretchingNameController.text.isNotEmpty
            ? stretchingNameController.text
            : null,
        'stretching_series': int.tryParse(stretchingSeriesController.text),
        'stretching_qty': int.tryParse(stretchingQtyController.text),
        'stretching_time': stretchingTimeController.text.isNotEmpty
            ? stretchingTimeController.text
            : null,
        'machine_photo_url': finalMachineUrl,
        'stretching_photo_url': finalStretchingUrl,
        'day_of_week': selectedDay,
        'workout_id': selectedWorkoutId,
      };

      if (exerciseId != null) {
        // UPDATE
        await GymExercisesTable().update(
          data: data,
          matchingRows: (t) => t.eq('id', exerciseId!),
        );
        ToastService.showSuccess('Exercício atualizado com sucesso!');
      } else {
        // INSERT
        data['created_at'] = DateTime.now().toIso8601String();
        await GymExercisesTable().insert(data);
        ToastService.showSuccess('Exercício salvo com sucesso!');
      }

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
