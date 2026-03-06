import 'dart:io';

import 'package:agricola/core/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers/mock_http_overrides.dart';

/// Tests that the URL guard logic used in profile screens correctly
/// prevents local file paths from reaching NetworkImage.
///
/// The profile screens use this pattern:
///   image: isNetworkUrl(profile.photoUrl)
///       ? DecorationImage(image: NetworkImage(profile.photoUrl!), ...)
///       : null,
///
/// These tests verify the guard with real-world URL values that have
/// caused production crashes.
void main() {
  setUp(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('Profile photo URL guard', () {
    Widget buildProfileAvatar(String? photoUrl) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: isNetworkUrl(photoUrl)
                  ? DecorationImage(
                      image: NetworkImage(photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !isNetworkUrl(photoUrl)
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
        ),
      );
    }

    testWidgets('shows NetworkImage for HTTPS URL', (tester) async {
      await tester.pumpWidget(buildProfileAvatar(
        'https://firebasestorage.googleapis.com/v0/b/bucket/o/photo.jpg',
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.image, isNotNull);
      expect(decoration.image!.image, isA<NetworkImage>());
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('shows fallback icon for file:// path (crash scenario)',
        (tester) async {
      // This is the exact URL pattern from the Crashlytics report
      await tester.pumpWidget(buildProfileAvatar(
        'file:///data/user/0/com.agricola.prod/cache/scaled_1000130396.jpg',
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.image, isNull,
          reason: 'file:// URI must not be passed to NetworkImage');
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows fallback icon for absolute file path', (tester) async {
      await tester.pumpWidget(buildProfileAvatar(
        '/data/user/0/com.agricola.prod/cache/photo.jpg',
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.image, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows fallback icon for null photoUrl', (tester) async {
      await tester.pumpWidget(buildProfileAvatar(null));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.image, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows fallback icon for content:// URI', (tester) async {
      await tester.pumpWidget(buildProfileAvatar(
        'content://com.android.providers.media/external/images/media/123',
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.image, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
