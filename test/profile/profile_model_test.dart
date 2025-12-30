// Package imports:
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/ui/pages/profile/profile.model.dart';
import '../mocks/mocks.dart';

class FakePostgrestTransformBuilderSingle extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final Map<String, dynamic>? result;
  FakePostgrestTransformBuilderSingle(this.result);

  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic>?) onValue, {
    Function? onError,
  }) {
    return Future.value(result).then(onValue, onError: onError);
  }
}

void main() {
  late ProfileModel model;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilderList mockFilterBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilderList();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.userMetadata).thenReturn({});

    // IMPORTANT: All builders implement Future, so use thenAnswer
    when(
      () => mockSupabaseClient.from(any()),
    ).thenAnswer((_) => mockQueryBuilder);
    when(
      () => mockQueryBuilder.select(any()),
    ).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.eq(any(), any()),
    ).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.maybeSingle(),
    ).thenAnswer((_) => FakePostgrestTransformBuilderSingle(null));

    model = ProfileModel(supabaseClient: mockSupabaseClient);
  });

  group('ProfileModel - loadUserData', () {
    test('should load user email and basic name if no metadata', () {
      model.loadUserData();

      expect(model.userEmail, 'test@example.com');
      expect(model.userName, 'test');
    });

    test('should load name from metadata if present', () {
      when(() => mockUser.userMetadata).thenReturn({
        'name': 'Franklyn Silva',
        'avatar_url': 'https://example.com/avatar.jpg',
      });

      model.loadUserData();

      expect(model.userName, 'Franklyn Silva');
      expect(model.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should fetch avatar from DB and override metadata', () async {
      when(
        () => mockUser.userMetadata,
      ).thenReturn({'avatar_url': 'https://example.com/metadata-avatar.jpg'});

      when(() => mockFilterBuilder.maybeSingle()).thenAnswer(
        (_) => FakePostgrestTransformBuilderSingle({
          'avatar_url': 'https://example.com/db-avatar.jpg',
          'username': 'franklyn_db',
        }),
      );

      model.loadUserData();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(model.avatarUrl, 'https://example.com/db-avatar.jpg');
      expect(model.userName, 'franklyn_db');
    });
  });
}
