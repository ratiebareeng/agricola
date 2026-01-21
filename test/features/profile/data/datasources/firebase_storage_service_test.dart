import 'dart:async';
import 'dart:io';

import 'package:agricola/features/profile/data/datasources/firebase_storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;
  late MockReference mockFileRef;
  late FirebaseStorageService storageService;

  setUpAll(() {
    registerFallbackValue(SettableMetadata());
    registerFallbackValue(FakeFile('/fake/path.jpg'));
  });

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();
    mockFileRef = MockReference();
    storageService = FirebaseStorageService(mockStorage);
  });

  group('FirebaseStorageService', () {
    group('uploadProfilePhoto', () {
      test('should upload JPEG image and return download URL', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.jpg');
        const downloadUrl = 'https://storage.googleapis.com/profile.jpg';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(() => mockRef.child('profiles/$userId/avatar.jpg')).called(1);
        verify(() => mockFileRef.putFile(any(), any())).called(1);
        verify(() => mockFileRef.getDownloadURL()).called(1);
      });

      test('should upload PNG image with correct content type', () async {
        const userId = 'user-456';
        final file = FakeFile('/path/to/photo.png');
        const downloadUrl = 'https://storage.googleapis.com/profile.png';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(() => mockRef.child('profiles/$userId/avatar.png')).called(1);
      });

      test('should handle upload errors', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.jpg');

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenThrow(FirebaseException(plugin: 'storage'));

        expect(
          () => storageService.uploadProfilePhoto(file, userId),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('deleteProfilePhoto', () {
      test('should delete all photos in user profile directory', () async {
        const userId = 'user-123';
        final mockListResult = MockListResult();
        final mockItem1 = MockReference();
        final mockItem2 = MockReference();

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(() => mockFileRef.list()).thenAnswer((_) async => mockListResult);
        when(() => mockListResult.items).thenReturn([mockItem1, mockItem2]);
        when(() => mockItem1.delete()).thenAnswer((_) async {});
        when(() => mockItem2.delete()).thenAnswer((_) async {});

        await storageService.deleteProfilePhoto(userId);

        verify(() => mockRef.child('profiles/$userId')).called(1);
        verify(() => mockFileRef.list()).called(1);
        verify(() => mockItem1.delete()).called(1);
        verify(() => mockItem2.delete()).called(1);
      });

      test('should handle object-not-found error gracefully', () async {
        const userId = 'user-123';

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(() => mockFileRef.list()).thenThrow(
          FirebaseException(plugin: 'storage', code: 'object-not-found'),
        );

        await storageService.deleteProfilePhoto(userId);

        verify(() => mockFileRef.list()).called(1);
      });

      test('should throw other Firebase exceptions', () async {
        const userId = 'user-123';

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.list(),
        ).thenThrow(FirebaseException(plugin: 'storage', code: 'unknown'));

        expect(
          () => storageService.deleteProfilePhoto(userId),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('content type detection', () {
      test('should detect JPEG content type', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.jpeg');
        const downloadUrl = 'https://storage.googleapis.com/profile.jpeg';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(() => mockRef.child('profiles/$userId/avatar.jpeg')).called(1);
      });

      test('should detect PNG content type', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.PNG');
        const downloadUrl = 'https://storage.googleapis.com/profile.PNG';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(() => mockRef.child('profiles/$userId/avatar.PNG')).called(1);
      });

      test('should detect GIF content type', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.gif');
        const downloadUrl = 'https://storage.googleapis.com/profile.gif';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(() => mockRef.child('profiles/$userId/avatar.gif')).called(1);
      });

      test('should detect WEBP content type', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.webp');
        const downloadUrl = 'https://storage.googleapis.com/profile.webp';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(() => mockRef.child('profiles/$userId/avatar.webp')).called(1);
      });

      test('should use default content type for unknown extensions', () async {
        const userId = 'user-123';
        final file = FakeFile('/path/to/photo.unknown');
        const downloadUrl = 'https://storage.googleapis.com/profile.unknown';

        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockFileRef);
        when(
          () => mockFileRef.putFile(any(), any()),
        ).thenAnswer((_) => fakeUploadTask);
        when(() => mockSnapshot.ref).thenReturn(mockFileRef);
        when(
          () => mockFileRef.getDownloadURL(),
        ).thenAnswer((_) async => downloadUrl);

        final result = await storageService.uploadProfilePhoto(file, userId);

        expect(result, downloadUrl);
        verify(
          () => mockRef.child('profiles/$userId/avatar.unknown'),
        ).called(1);
      });
    });
  });
}

class FakeFile extends Fake implements File {
  @override
  final String path;

  FakeFile(this.path);
}

class FakeUploadTask extends Fake implements UploadTask {
  final Future<TaskSnapshot> _future;

  FakeUploadTask(TaskSnapshot snapshot) : _future = Future.value(snapshot);

  @override
  Stream<TaskSnapshot> asStream() {
    return _future.asStream();
  }

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) {
    return _future.catchError(onError, test: test);
  }

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) {
    return _future.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) {
    return _future.whenComplete(action);
  }
}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockListResult extends Mock implements ListResult {}

class MockReference extends Mock implements Reference {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

class MockUploadTask extends Mock implements UploadTask {}
