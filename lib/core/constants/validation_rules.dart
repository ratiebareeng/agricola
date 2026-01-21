class ValidationRules {
  // Profile validation
  static const int minBusinessNameLength = 3;
  static const int maxBusinessNameLength = 100;
  static const int minVillageLength = 2;
  static const int maxVillageLength = 100;
  static const int maxPrimaryCropsCount = 5;
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024; // 5MB

  // Error messages
  static const String businessNameTooShort =
      'Business name must be at least $minBusinessNameLength characters';
  static const String businessNameTooLong =
      'Business name cannot exceed $maxBusinessNameLength characters';
  static const String villageRequired = 'Village is required';
  static const String cropsRequired = 'Select at least one primary crop';
  static const String farmSizeRequired = 'Farm size is required';
  static const String photoTooLarge =
      'Photo must be smaller than ${maxPhotoSizeBytes ~/ (1024 * 1024)}MB';
}
