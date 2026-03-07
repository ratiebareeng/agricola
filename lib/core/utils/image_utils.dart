import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Magic byte signatures for supported image formats
const _jpegMagic = [0xFF, 0xD8, 0xFF];
const _pngMagic = [0x89, 0x50, 0x4E, 0x47];

class ImageUtils {
  /// Compress image for profile upload
  /// Target: < 500KB, max 800x800
  /// Throws if the file is not a valid image.
  static Future<File> compressProfileImage(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      'compressed_${path.basename(imageFile.path)}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 800,
      minHeight: 800,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw FormatException('File is not a valid image: ${imageFile.path}');
    }

    return File(result.path);
  }

  /// Compress image for product/marketplace upload
  /// Target: < 1MB, max 1200x1200
  /// Throws if the file is not a valid image.
  static Future<File> compressProductImage(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      'product_${path.basename(imageFile.path)}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1200,
      minHeight: 1200,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw FormatException('File is not a valid image: ${imageFile.path}');
    }

    return File(result.path);
  }

  /// Validate image file
  /// Checks: size < 5MB, allowed extension, and magic bytes match a real image
  static Future<bool> validateImage(File imageFile) async {
    final bytes = await imageFile.length();
    if (bytes > 5 * 1024 * 1024) {
      return false;
    }

    final ext = path.extension(imageFile.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png'].contains(ext)) {
      return false;
    }

    // Verify magic bytes to ensure the file is actually an image
    if (!await _hasValidMagicBytes(imageFile)) {
      return false;
    }

    return true;
  }

  /// Check file header bytes against known image format signatures.
  static Future<bool> _hasValidMagicBytes(File file) async {
    try {
      final raf = await file.open(mode: FileMode.read);
      try {
        final Uint8List header = await raf.read(4);
        if (header.length < 3) return false;

        // JPEG: FF D8 FF
        if (header[0] == _jpegMagic[0] &&
            header[1] == _jpegMagic[1] &&
            header[2] == _jpegMagic[2]) {
          return true;
        }

        // PNG: 89 50 4E 47
        if (header.length >= 4 &&
            header[0] == _pngMagic[0] &&
            header[1] == _pngMagic[1] &&
            header[2] == _pngMagic[2] &&
            header[3] == _pngMagic[3]) {
          return true;
        }

        return false;
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }
}
