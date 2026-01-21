import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Compress image for profile upload
  /// Target: < 500KB, max 800x800
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

    return result != null ? File(result.path) : imageFile;
  }

  /// Validate image file
  /// Checks: size < 5MB, format is image
  static Future<bool> validateImage(File imageFile) async {
    final bytes = await imageFile.length();
    if (bytes > 5 * 1024 * 1024) {
      return false;
    }

    final ext = path.extension(imageFile.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png'].contains(ext)) {
      return false;
    }

    return true;
  }
}
