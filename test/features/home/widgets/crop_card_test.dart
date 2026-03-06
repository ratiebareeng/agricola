import 'dart:io';

import 'package:agricola/features/home/widgets/crop_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers/mock_http_overrides.dart';

void main() {
  group('CropCard', () {
    Widget buildCard({required String imageUrl}) {
      return MaterialApp(
        home: Scaffold(
          body: CropCard(
            name: 'North Field',
            stage: 'Vegetative',
            plantedDate: 'Jan 1, 2026',
            progress: 0.5,
            imageUrl: imageUrl,
          ),
        ),
      );
    }

    setUp(() {
      HttpOverrides.global = MockHttpOverrides();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    testWidgets('renders with valid HTTP image URL', (tester) async {
      await tester.pumpWidget(buildCard(
        imageUrl: 'https://example.com/crops/maize.jpg',
      ));

      expect(find.text('North Field'), findsOneWidget);
      expect(find.text('Vegetative'), findsOneWidget);
      expect(find.text('Planted: Jan 1, 2026'), findsOneWidget);
    });

    testWidgets('displays progress indicator', (tester) async {
      await tester.pumpWidget(buildCard(
        imageUrl: 'https://example.com/photo.jpg',
      ));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('uses NetworkImage for decoration', (tester) async {
      await tester.pumpWidget(buildCard(
        imageUrl: 'https://example.com/crops/maize.jpg',
      ));

      final imageContainer = tester.widgetList<Container>(
        find.byType(Container),
      ).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.image != null;
        }
        return false;
      });

      expect(imageContainer, isNotEmpty);
      final decoration = imageContainer.first.decoration as BoxDecoration;
      expect(decoration.image!.image, isA<NetworkImage>());
      expect(
        (decoration.image!.image as NetworkImage).url,
        'https://example.com/crops/maize.jpg',
      );
    });
  });
}
