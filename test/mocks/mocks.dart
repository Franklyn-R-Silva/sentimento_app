// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:sentimento_app/auth/auth_manager.dart';
import 'package:sentimento_app/auth/supabase_auth/supabase_auth_manager.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthManager extends Mock implements AuthManager {}

class MockSupabaseAuthManager extends Mock implements SupabaseAuthManager {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilderList extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilderSingle extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockBuildContext extends Mock implements BuildContext {
  @override
  bool get mounted => true;

  @override
  Widget get widget => Container();
}
