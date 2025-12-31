// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/ui/pages/profile/profile.model.dart';
import '../mocks/mocks.dart';

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

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(model.avatarUrl, 'https://example.com/db-avatar.jpg');
      expect(model.userName, 'franklyn_db');
    });
  });

  group('ProfileModel - uploadAvatarImage', () {
    testWidgets('should upload image and update avatarUrl on success', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => model.uploadAvatarImage(context),
                  child: const Text('Upload'),
                );
              },
            ),
          ),
        ),
      );

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

      // Trigger upload via button press to get valid context
      await tester.tap(find.text('Upload'));
      await tester.pump(); // Start async operation

      // Simulate async completion
      await tester.pump(const Duration(milliseconds: 100));

      expect(model.avatarUrl, 'https://example.com/new-avatar.jpg');
      verify(
        () => mockFileApi.uploadBinary(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).called(1);
      expect(model.isUploading, false);
    });
  });
}
