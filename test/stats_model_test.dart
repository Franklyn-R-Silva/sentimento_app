import 'package:flutter_test/flutter_test.dart';
import 'package:sentimento_app/ui/pages/stats/stats.model.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';

void main() {
  late StatsModel model;

  setUp(() {
    model = StatsModel();
  });

  group('StatsModel Calculations', () {
    test('calculateStreaks should return 0s for empty list', () {
      final streaks = model.calculateStreaks([]);
      expect(streaks['current'], 0);
      expect(streaks['longest'], 0);
    });

    test(
      'calculateStreaks should correctly calculate current and longest streaks',
      () {
        final now = DateTime.now();
        final entries = [
          EntradasHumorRow({'criado_em': now.toIso8601String()}),
          EntradasHumorRow({
            'criado_em': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          }),
          EntradasHumorRow({
            'criado_em': now
                .subtract(const Duration(days: 2))
                .toIso8601String(),
          }),
          // Jump 2 days
          EntradasHumorRow({
            'criado_em': now
                .subtract(const Duration(days: 5))
                .toIso8601String(),
          }),
          EntradasHumorRow({
            'criado_em': now
                .subtract(const Duration(days: 6))
                .toIso8601String(),
          }),
        ];

        final streaks = model.calculateStreaks(entries);
        expect(streaks['current'], 3);
        expect(streaks['longest'], 3);
      },
    );

    test('calculateStreaks should detect broken current streak', () {
      final now = DateTime.now();
      final entries = [
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 2)).toIso8601String(),
        }),
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 3)).toIso8601String(),
        }),
      ];

      final streaks = model.calculateStreaks(entries);
      expect(streaks['current'], 0); // Broken since last entry was 2 days ago
      expect(streaks['longest'], 2);
    });
  });
}
