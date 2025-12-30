import 'package:flutter_test/flutter_test.dart';
import 'package:sentimento_app/ui/pages/home/home.model.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';

void main() {
  late HomeModel model;

  setUp(() {
    model = HomeModel();
  });

  group('HomeModel Streak Calculations', () {
    test('calculateLongestStreak should return 0 for empty list', () {
      expect(model.calculateLongestStreak([]), 0);
    });

    test('calculateLongestStreak should correctly count consecutive days', () {
      final now = DateTime.now();
      final entries = [
        EntradasHumorRow({'criado_em': now.toIso8601String()}),
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 1)).toIso8601String(),
        }),
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 2)).toIso8601String(),
        }),
        // Jump 1 day
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 4)).toIso8601String(),
        }),
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 5)).toIso8601String(),
        }),
      ];

      expect(model.calculateLongestStreak(entries), 3);
    });

    test('calculateCurrentStreak should return 0 for empty list', () {
      expect(model.calculateCurrentStreak([]), 0);
    });

    test('calculateCurrentStreak should detect if streak is active today', () {
      final now = DateTime.now();
      final entries = [
        EntradasHumorRow({'criado_em': now.toIso8601String()}),
        EntradasHumorRow({
          'criado_em': now.subtract(const Duration(days: 1)).toIso8601String(),
        }),
      ];

      expect(model.calculateCurrentStreak(entries), 2);
    });

    test(
      'calculateCurrentStreak should detect if streak is active starting yesterday',
      () {
        final now = DateTime.now();
        final entries = [
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
        ];

        expect(model.calculateCurrentStreak(entries), 2);
      },
    );

    test(
      'calculateCurrentStreak should return 0 if last entry was 2 days ago',
      () {
        final now = DateTime.now();
        final entries = [
          EntradasHumorRow({
            'criado_em': now
                .subtract(const Duration(days: 2))
                .toIso8601String(),
          }),
        ];

        expect(model.calculateCurrentStreak(entries), 0);
      },
    );

    test(
      'calculateLongestStreak should handle multiple entries on same day',
      () {
        final now = DateTime.now();
        final entries = [
          EntradasHumorRow({'criado_em': now.toIso8601String()}),
          EntradasHumorRow({'criado_em': now.toIso8601String()}),
          EntradasHumorRow({
            'criado_em': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          }),
        ];

        expect(model.calculateLongestStreak(entries), 2);
      },
    );
  });
}
