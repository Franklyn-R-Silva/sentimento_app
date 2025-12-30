// Package imports:
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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

class FakePostgrestFilterBuilderList extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> result;
  final Map<String, dynamic>? singleResult;
  FakePostgrestFilterBuilderList(this.result, {this.singleResult});

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
    String column,
    Object value,
  ) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> update(
    Map<String, dynamic> values,
  ) => this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    return FakePostgrestTransformBuilderSingle(singleResult);
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(List<Map<String, dynamic>>) onValue, {
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
  late MockImagePicker mockImagePicker;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockFileApi;
  late MockXFile mockXFile;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockImagePicker = MockImagePicker();
    mockStorageClient = MockSupabaseStorageClient();
    mockFileApi = MockStorageFileApi();
    mockXFile = MockXFile();

    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const FileOptions());

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.userMetadata).thenReturn({});

    // Use thenAnswer for anything that implements Future
    when(
      () => mockSupabaseClient.from(any()),
    ).thenAnswer((_) => mockQueryBuilder);
    when(
      () => mockQueryBuilder.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilderList([]));
    when(
      () => mockQueryBuilder.update(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilderList([]));

    when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
    when(() => mockStorageClient.from(any())).thenReturn(mockFileApi);

    model = ProfileModel(
      supabaseClient: mockSupabaseClient,
      imagePicker: mockImagePicker,
    );
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

      when(() => mockQueryBuilder.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilderList(
          [],
          singleResult: {
            'avatar_url': 'https://example.com/db-avatar.jpg',
            'username': 'franklyn_db',
          },
        ),
      );

      model.loadUserData();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(model.avatarUrl, 'https://example.com/db-avatar.jpg');
      expect(model.userName, 'franklyn_db');
    });
  });

  group('ProfileModel - uploadAvatarImage', () {
    test('should upload image and update avatarUrl on success', () async {
      final context = MockBuildContext();

      when(
        () => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => mockXFile);

      when(() => mockXFile.readAsBytes()).thenAnswer((_) async => Uint8List(0));
      when(() => mockXFile.path).thenReturn('test.jpg');

      when(
        () => mockFileApi.uploadBinary(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((_) async => 'path/to/upload');

      when(
        () => mockFileApi.getPublicUrl(any()),
      ).thenReturn('https://example.com/new-avatar.jpg');

      when(
        () => mockQueryBuilder.update(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilderList([]));

      try {
        await model.uploadAvatarImage(context);
      } catch (e) {
        if (!e.toString().contains('ScaffoldMessenger')) rethrow;
      }

      expect(model.avatarUrl, 'https://example.com/new-avatar.jpg');
      expect(model.isUploading, false);
    });
  });
}
