#!/bin/bash

# Fix thenReturn(fakeUploadTask) to thenAnswer((_) => fakeUploadTask)
sed -i '' 's/).thenReturn(fakeUploadTask);/).thenAnswer((_) => fakeUploadTask);/g' /Users/ratiebareeng/Documents/GitHub/agricola/test/features/profile/data/datasources/firebase_storage_service_test.dart

echo "Fixed firebase_storage_service_test.dart"
echo "Run: flutter test test/features/profile/data/datasources/firebase_storage_service_test.dart"
