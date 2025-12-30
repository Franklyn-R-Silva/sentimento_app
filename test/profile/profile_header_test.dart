import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentimento_app/ui/pages/profile/widgets/profile_header.dart';

// Helper to mock HTTP responses for Image.network
class MockHttpOverrides extends HttpOverrides {
  final Map<String, List<int>> _responses = {};
  final Set<String> _errorUrls = {};
  final Duration? delay;

  MockHttpOverrides({this.delay});

  void addResponse(String url, List<int> response) {
    _responses[url] = response;
  }

  void addError(String url) {
    _errorUrls.add(url);
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient(_responses, _errorUrls, delay);
  }
}

class MockHttpClient extends Fake implements HttpClient {
  final Map<String, List<int>> responses;
  final Set<String> errorUrls;
  final Duration? delay;

  MockHttpClient(this.responses, this.errorUrls, this.delay);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest(
      responses[url.toString()],
      errorUrls.contains(url.toString()),
      delay,
    );
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  final List<int>? response;
  final bool isError;
  final Duration? delay;

  MockHttpClientRequest(this.response, this.isError, this.delay);

  @override
  Future<HttpClientResponse> close() async {
    if (delay != null) {
      await Future.delayed(delay!);
    }
    if (isError) {
      throw Exception('Network Error');
    }
    return MockHttpClientResponse(response ?? []);
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  final List<int> data;
  MockHttpClientResponse(this.data);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => data.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([data]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  const testEmail = 'franklyn@example.com';
  const testName = 'Franklyn Silva';
  const testAvatarUrl = 'https://example.com/avatar.jpg';

  // Transparent pixel for successful image test
  final transparentPixel = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x08,
    0xD7,
    0x63,
    0x60,
    0x00,
    0x02,
    0x00,
    0x01,
    0xE5,
    0x27,
    0xDE,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  testWidgets('should show initials when avatarUrl is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            userName: testName,
            userEmail: testEmail,
            avatarUrl: null,
            isUploading: false,
          ),
        ),
      ),
    );

    expect(find.text('FS'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('should show initials when avatarUrl is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            userName: testName,
            userEmail: testEmail,
            avatarUrl: '',
            isUploading: false,
          ),
        ),
      ),
    );

    expect(find.text('FS'), findsOneWidget);
  });

  testWidgets('should show loading indicator while image is loading', (
    WidgetTester tester,
  ) async {
    final overrides = MockHttpOverrides(delay: const Duration(seconds: 1));
    overrides.addResponse(testAvatarUrl, transparentPixel);

    HttpOverrides.global = overrides;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            userName: testName,
            userEmail: testEmail,
            avatarUrl: testAvatarUrl,
            isUploading: false,
          ),
        ),
      ),
    );

    // Initially should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for image to load
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(); // Second pump for image to settle

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Image), findsOneWidget);

    HttpOverrides.global = null;
  });

  testWidgets('should show initials on network error', (
    WidgetTester tester,
  ) async {
    final overrides = MockHttpOverrides();
    overrides.addError(testAvatarUrl);

    HttpOverrides.global = overrides;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            userName: testName,
            userEmail: testEmail,
            avatarUrl: testAvatarUrl,
            isUploading: false,
          ),
        ),
      ),
    );

    await tester.pump(); // Trigger error

    expect(find.text('FS'), findsOneWidget);

    HttpOverrides.global = null;
  });

  testWidgets('should show initials on upload state even if URL exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            userName: testName,
            userEmail: testEmail,
            avatarUrl: testAvatarUrl,
            isUploading: true,
          ),
        ),
      ),
    );

    // When uploading, we show initials + indicator
    expect(find.text('FS'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
