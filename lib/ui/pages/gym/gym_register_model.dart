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

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

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

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (image != null) {
      _selectedImage = image;
      notifyListeners();
    }
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      final fileBytes = await _selectedImage!.readAsBytes();
      final fileExt = _selectedImage!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$userId/$fileName';

      final supabase = Supabase.instance.client;
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

      return publicUrl;
    } catch (e) {
      Logger().e('Error uploading image: $e');
      throw Exception('Falha ao upar imagem');
    }
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

      String? imageUrl;
      if (_selectedImage != null) {
        try {
          imageUrl = await _uploadImage(userId);
        } catch (e) {
          ToastService.showError(
            'Erro ao salvar foto. Verifique se o bucket "gym_photos" existe.',
          );
          // Proceed without image? Or stop? Let's stop to be safe or maybe user wants to save anyway.
          // For now, let's stop but log it.
          // Actually, let's try to proceed without image if upload fails but warn user?
          // No, simplicity: fail if upload fails.
          isLoading = false;
          return false;
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
        'machine_photo_url': imageUrl,
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
