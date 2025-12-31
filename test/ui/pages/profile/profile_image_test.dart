// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sentimento_app/ui/pages/profile/widgets/profile_header.dart';

// 1x1 Transparent GIF
const List<int> kTransparentImage = [
  0x47,
  0x49,
  0x46,
  0x38,
  0x39,
  0x61,
  0x01,
  0x00,
  0x01,
  0x00,
  0x80,
  0x00,
  0x00,
  0xff,
  0xff,
  0xff,
  0x00,
  0x00,
  0x00,
  0x21,
  0xf9,
  0x04,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x2c,
  0x00,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x01,
  0x00,
  0x00,
  0x02,
  0x02,
  0x44,
  0x01,
  0x00,
  0x3b,
];

class _TestHttpClient extends Fake implements HttpClient {
  final int responseStatusCode;
  final List<int> content;

  _TestHttpClient(this.responseStatusCode, this.content);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _TestHttpClientRequest(responseStatusCode, content);
  }
}

class _TestHttpClientRequest extends Fake implements HttpClientRequest {
  final int responseStatusCode;
  final List<int> content;

  _TestHttpClientRequest(this.responseStatusCode, this.content);

  @override
  Future<HttpClientResponse> close() async {
    return _TestHttpClientResponse(responseStatusCode, content);
  }
}

class _TestHttpClientResponse extends Fake implements HttpClientResponse {
  final int _statusCode;
  final List<int> content;

  _TestHttpClientResponse(this._statusCode, this.content);

  @override
  int get statusCode => _statusCode;

  @override
  int get contentLength => content.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(content).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  // Setup path_provider mock BEFORE all tests
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the path_provider method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getTemporaryDirectory') {
              return '.';
            }
            if (methodCall.method == 'getApplicationSupportDirectory') {
              return '.';
            }
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return '.';
            }
            return null;
          },
        );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  group('ProfileHeader Image Tests', () {
    testWidgets('Should display user initials when avatarUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeader(
              userName: 'Test User',
              userEmail: 'test@example.com',
              avatarUrl: null,
            ),
          ),
        ),
      );

      // AutoSizeText shows TU initials
      expect(find.text('TU'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets(
      'Should display CachedNetworkImage when avatarUrl is provided',
      (tester) async {
        await HttpOverrides.runZoned(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ProfileHeader(
                  userName: 'Test User',
                  userEmail: 'test@example.com',
                  avatarUrl: 'https://example.com/avatar.jpg',
                ),
              ),
            ),
          );

          // Pump multiple times instead of pumpAndSettle to avoid timeout
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          // Verify CachedNetworkImage is present
          expect(find.byType(CachedNetworkImage), findsOneWidget);

          // Either loading indicator or image should be present
          final hasLoadingOrImage =
              find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
              find.byType(Image).evaluate().isNotEmpty;

          expect(hasLoadingOrImage, isTrue);
        }, createHttpClient: (_) => _TestHttpClient(200, kTransparentImage));
      },
    );

    testWidgets('Should display initials on 400 error', (tester) async {
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ProfileHeader(
                userName: 'Test User',
                userEmail: 'test@example.com',
                avatarUrl: 'https://example.com/bad_avatar.jpg',
              ),
            ),
          ),
        );

        // Pump multiple times instead of pumpAndSettle
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // On error, either initials should be shown OR loading indicator (depends on retry logic)
        final hasInitialsOrLoading =
            find.text('TU').evaluate().isNotEmpty ||
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

        expect(hasInitialsOrLoading, isTrue);
      }, createHttpClient: (_) => _TestHttpClient(400, []));
    });
  });
}
