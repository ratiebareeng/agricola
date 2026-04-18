import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Magic byte signatures for supported image formats
const _jpegMagic = [0xFF, 0xD8, 0xFF];
const _pngMagic = [0x89, 0x50, 0x4E, 0x47];

const _maxUploadBytes = 5 * 1024 * 1024; // 5 MB post-compression safety ceiling

enum ImagePreset { profile, product }

class PreparedImage {
  final File? file;
  final String? errorKey;
  const PreparedImage._({this.file, this.errorKey});

  factory PreparedImage.ok(File f) => PreparedImage._(file: f);
  factory PreparedImage.err(String key) => PreparedImage._(errorKey: key);

  bool get ok => file != null;
}

class ImageUtils {
  /// Validates extension + magic bytes, compresses, then checks final size.
  /// Returns a PreparedImage — check .ok before using .file.
  static Future<PreparedImage> prepare(File raw, {required ImagePreset preset}) async {
    final ext = path.extension(raw.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png'].contains(ext)) {
      return PreparedImage.err('image_invalid_format');
    }

    if (!await _hasValidMagicBytes(raw)) {
      return PreparedImage.err('image_invalid_format');
    }

    final File compressed;
    try {
      compressed = preset == ImagePreset.profile
          ? await _compressProfile(raw)
          : await _compressProduct(raw);
    } catch (_) {
      return PreparedImage.err('image_invalid_format');
    }

    if (await compressed.length() > _maxUploadBytes) {
      return PreparedImage.err('image_too_large_even_compressed');
    }

    return PreparedImage.ok(compressed);
  }

  /// Compress image for profile upload — target <500 KB, max 800×800.
  static Future<File> compressProfileImage(File imageFile) => _compressProfile(imageFile);

  /// Compress image for product/marketplace upload — target <1 MB, max 1200×1200.
  static Future<File> compressProductImage(File imageFile) => _compressProduct(imageFile);

  // ---- private ----

  static Future<File> _compressProfile(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, 'compressed_${path.basename(imageFile.path)}');
    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 800,
      minHeight: 800,
      format: CompressFormat.jpeg,
    );
    if (result == null) throw FormatException('Not a valid image: ${imageFile.path}');
    return File(result.path);
  }

  static Future<File> _compressProduct(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, 'product_${path.basename(imageFile.path)}');
    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1200,
      minHeight: 1200,
      format: CompressFormat.jpeg,
    );
    if (result == null) throw FormatException('Not a valid image: ${imageFile.path}');
    return File(result.path);
  }

  static Future<bool> _hasValidMagicBytes(File file) async {
    try {
      final raf = await file.open(mode: FileMode.read);
      try {
        final Uint8List header = await raf.read(4);
        if (header.length < 3) return false;
        if (header[0] == _jpegMagic[0] && header[1] == _jpegMagic[1] && header[2] == _jpegMagic[2]) return true;
        if (header.length >= 4 && header[0] == _pngMagic[0] && header[1] == _pngMagic[1] && header[2] == _pngMagic[2] && header[3] == _pngMagic[3]) return true;
        return false;
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }
}
