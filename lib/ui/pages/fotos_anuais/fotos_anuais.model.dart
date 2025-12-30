import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentimento_app/backend/supabase.dart' hide LatLng;
import 'package:sentimento_app/core/model.dart';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_cropper/image_cropper.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

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

  ll.LatLng? _currentLocation;
  ll.LatLng? get currentLocation => _currentLocation;
  set currentLocation(ll.LatLng? value) {
    _currentLocation = value;
    notifyListeners();
  }

  bool _isFetchingLocation = false;
  bool get isFetchingLocation => _isFetchingLocation;

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

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      if (!kIsWeb && Platform.isWindows && source == ImageSource.camera) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A câmera não está disponível nativamente no Windows. Por favor, use a Galeria para selecionar um arquivo.',
            ),
          ),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null) {
        if (!context.mounted) return;

        // Integrate Image Cropper
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Editar Foto',
              toolbarColor: FlutterFlowTheme.of(context).primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
            IOSUiSettings(
              title: 'Editar Foto',
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
              size: const CropperSize(width: 520, height: 520),
            ),
          ],
        );

        if (croppedFile != null) {
          _selectedImageBytes = await croppedFile.readAsBytes();
          _imageName = image.name;

          if (!context.mounted) return;
          // Proactively fetch location when photo is picked
          await fetchCurrentLocation(context);

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> fetchCurrentLocation(BuildContext context) async {
    _isFetchingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Os serviços de localização estão desativados.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'As permissões de localização foram negadas.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'As permissões de localização estão permanentemente negadas.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentLocation = ll.LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro de localização: $e')));
      }
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
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
          '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = 'users/$userId/$fileName';

      await supabase.storage
          .from('fotos_anuais')
          .uploadBinary(
            storagePath,
            _selectedImageBytes!,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/$fileExtension',
            ),
          );

      final imageUrl = supabase.storage
          .from('fotos_anuais')
          .getPublicUrl(storagePath);

      // 2. Save to Database
      await FotosAnuaisTable().insert({
        'user_id': userId,
        'image_url': imageUrl,
        'frase': fraseController.text.isNotEmpty ? fraseController.text : null,
        'mood_level': _moodLevel,
        'lat': _currentLocation?.latitude,
        'lng': _currentLocation?.longitude,
        'data_foto': _selectedDate.toIso8601String(),
      });

      if (!context.mounted) return true;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto salva com sucesso!')));

      // Clear selection
      _selectedImageBytes = null;
      _imageName = null;
      _moodLevel = null;
      _currentLocation = null;
      fraseController.clear();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar foto: $e')));
      }
      return false;
    } finally {
      isUploading = false;
    }
  }
}
