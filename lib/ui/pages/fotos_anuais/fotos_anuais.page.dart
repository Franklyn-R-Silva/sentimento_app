import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/fotos_anuais/fotos_anuais.model.dart';
import 'widgets/location_selection_widget.dart';
import 'widgets/photo_capture_widget.dart';
import 'widgets/mood_selector_widget.dart';
import 'widgets/phrase_input_widget.dart';
import 'widgets/date_time_selector_widget.dart';

class FotosAnuaisPage extends StatefulWidget {
  const FotosAnuaisPage({super.key});

  @override
  State<FotosAnuaisPage> createState() => _FotosAnuaisPageState();
}

class _FotosAnuaisPageState extends State<FotosAnuaisPage> {
  late FotosAnuaisModel _model;

  @override
  void initState() {
    super.initState();
    _model = FotosAnuaisModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<FotosAnuaisModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: theme.primary,
              automaticallyImplyLeading: true,
              title: Text(
                'Fotos 365 Dias',
                style: theme.typography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              actions: [
                if (model.isUploading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      final success = await model.savePhoto(context);
                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
              centerTitle: false,
              elevation: 2,
            ),
            body: SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 1. Photo Capture & Preview
                      PhotoCaptureWidget(model: model),

                      const SizedBox(height: 16),

                      // 2. Location Selection
                      LocationSelectionWidget(model: model),

                      const SizedBox(height: 16),

                      // 3. Mood Selector
                      MoodSelectorWidget(model: model),

                      const SizedBox(height: 16),

                      // 4. Phrase Input
                      PhraseInputWidget(model: model),

                      const SizedBox(height: 16),

                      // 5. Date & Time Selector
                      DateTimeSelectorWidget(model: model),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
