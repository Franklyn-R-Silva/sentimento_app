import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import '../fotos_anuais.model.dart';

class PhotoCaptureWidget extends StatelessWidget {
  final FotosAnuaisModel model;

  const PhotoCaptureWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GradientCard(
      moodLevel: model.moodLevel ?? 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (model.selectedImageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  model.selectedImageBytes!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma foto selecionada',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Tirar Foto',
                    onTap: () => model.pickImage(context, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    context,
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onTap: () => model.pickImage(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
