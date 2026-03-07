import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService(this._storage);

  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final listResult = await _storage.ref().child('profiles/$userId').list();

      for (final item in listResult.items) {
        await item.delete();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto(File file, String userId) async {
    final fileName = 'avatar${path.extension(file.path)}';
    final ref = _storage.ref().child('profiles/$userId/$fileName');

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: _getContentType(file.path),
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      ),
    );

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Upload a marketplace listing image.
  /// Returns the download URL.
  Future<String> uploadMarketplaceImage(
    File file,
    String userId, {
    String? listingId,
    int index = 0,
  }) async {
    final folder = listingId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final fileName = 'image_$index${path.extension(file.path)}';
    final ref = _storage.ref().child('marketplace/$userId/$folder/$fileName');

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: _getContentType(file.path),
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  String _getContentType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        // After compression, files are always JPEG
        return 'image/jpeg';
    }
  }
}
