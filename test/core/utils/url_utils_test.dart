import 'package:agricola/core/utils/url_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isNetworkUrl', () {
    test('returns true for HTTPS URL', () {
      expect(isNetworkUrl('https://example.com/photo.jpg'), isTrue);
    });

    test('returns true for HTTP URL', () {
      expect(isNetworkUrl('http://example.com/photo.jpg'), isTrue);
    });

    test('returns true for Firebase Storage URL', () {
      expect(
        isNetworkUrl(
          'https://firebasestorage.googleapis.com/v0/b/bucket/o/photo.jpg',
        ),
        isTrue,
      );
    });

    test('returns false for file:// URI', () {
      expect(
        isNetworkUrl(
          'file:///data/user/0/com.agricola.prod/cache/scaled_123.jpg',
        ),
        isFalse,
      );
    });

    test('returns false for absolute file path without scheme', () {
      expect(
        isNetworkUrl('/data/user/0/com.agricola.prod/cache/photo.jpg'),
        isFalse,
      );
    });

    test('returns false for relative path', () {
      expect(isNetworkUrl('images/photo.jpg'), isFalse);
    });

    test('returns false for null', () {
      expect(isNetworkUrl(null), isFalse);
    });

    test('returns false for empty string', () {
      expect(isNetworkUrl(''), isFalse);
    });

    test('returns false for content:// URI (Android)', () {
      expect(
        isNetworkUrl(
          'content://com.android.providers.media/external/images/123',
        ),
        isFalse,
      );
    });
  });
}
