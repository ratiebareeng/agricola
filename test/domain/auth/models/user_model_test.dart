import 'package:agricola/domain/domain.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';

/// Test merchant user
final testMerchantUser = UserModel(
  uid: 'test-merchant-789',
  email: 'merchant@example.com',
  emailVerified: true,
  userType: UserType.merchant,
  isProfileComplete: true,
  createdAt: DateTime(2025, 1, 1),
);

/// Test user for use in tests
final testUser = UserModel(
  uid: 'test-user-123',
  email: 'test@example.com',
  emailVerified: true,
  userType: UserType.farmer,
  isProfileComplete: true,
  createdAt: DateTime(2025, 1, 1),
);

/// Test user with incomplete profile
final testUserIncompleteProfile = UserModel(
  uid: 'test-user-456',
  email: 'test2@example.com',
  emailVerified: true,
  userType: UserType.farmer,
  isProfileComplete: false,
  createdAt: DateTime(2025, 1, 1),
);
