// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter_animate/flutter_animate.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

class BreathingExerciseSheet extends StatefulWidget {
  final FlutterFlowTheme theme;

  const BreathingExerciseSheet({super.key, required this.theme});

  @override
  State<BreathingExerciseSheet> createState() => _BreathingExerciseSheetState();
}

class _BreathingExerciseSheetState extends State<BreathingExerciseSheet>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _instruction = 'Inspire';
  bool _isRunning = false;
  String _selectedSound = 'silence'; // silence, rain, forest

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = 'Expire');
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = 'Inspire');
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleExercise() async {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _controller.forward();
      // TODO: Add actual sound files to assets/sounds/
      // if (_selectedSound != 'silence') {
      //   await _audioPlayer.play(AssetSource('sounds/$_selectedSound.mp3'));
      //   await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // }
    } else {
      _controller.stop();
      await _audioPlayer.stop();
    }
  }

  void _showPanicDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            Text('Técnica 5-4-3-2-1', style: widget.theme.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acalme sua mente focando no agora:',
              style: widget.theme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildGroundingStep('👀', '5 coisas que você vê'),
            _buildGroundingStep('✋', '4 coisas que você toca'),
            _buildGroundingStep('👂', '3 coisas que você ouve'),
            _buildGroundingStep('👃', '2 coisas que você cheira'),
            _buildGroundingStep('👅', '1 coisa que você sente o gosto'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Estou melhor',
              style: TextStyle(color: widget.theme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroundingStep(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(text, style: widget.theme.bodyMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with SOS button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Respiração Guiada',
                  style: theme.headlineSmall.override(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  onPressed: _showPanicDialog,
                  icon: const Icon(Icons.sos_rounded, color: Color(0xFFE53935)),
                  tooltip: 'Ajuda Imediata (Pânico)',
                ),
              ],
            ),
          ),

          const Spacer(),

          // Breathing Circle
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                    width: 250 * _animation.value,
                    height: 250 * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.primary.withValues(alpha: 0.6),
                          theme.secondary.withValues(alpha: 0.4),
                          theme.tertiary.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withValues(alpha: 0.3),
                          blurRadius: 30 * _animation.value,
                          spreadRadius: 5 * _animation.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isRunning ? _instruction : 'Toque\npara iniciar',
                        textAlign: TextAlign.center,
                        style: theme.headlineMedium.override(
                          color: Colors.white,
                          fontSize: 24 * _animation.value,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .animate(target: _isRunning ? 1 : 0)
                  .shimmer(duration: 2.seconds);
            },
          ),

          const Spacer(),

          // Sound Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sons de Fundo (Em breve)', style: theme.labelMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSoundOption(
                      theme,
                      'Silêncio',
                      'silence',
                      Icons.volume_off,
                    ),
                    _buildSoundOption(theme, 'Chuva', 'rain', Icons.water_drop),
                    _buildSoundOption(
                      theme,
                      'Floresta',
                      'forest',
                      Icons.forest,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? theme.error : theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: Icon(
                  _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                label: Text(
                  _isRunning ? 'Encerrar Sessão' : 'Iniciar Respiração',
                  style: theme.titleMedium.override(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundOption(
    FlutterFlowTheme theme,
    String label,
    String id,
    IconData icon,
  ) {
    final isSelected = _selectedSound == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSound = id),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primary.withOpacity(0.1)
                  : theme.primaryBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.primary : theme.alternate,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? theme.primary : theme.secondaryText,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.bodySmall.override(
              color: isSelected ? theme.primary : theme.secondaryText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
