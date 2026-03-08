import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/domain/auth/models/user_model_firebase.dart';
import 'package:agricola_core/agricola_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  group('UserModel', () {
    final now = DateTime(2026, 1, 15, 10, 30);

    group('constructor', () {
      test('should create with required fields and defaults', () {
        final user = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );

        expect(user.uid, 'uid1');
        expect(user.email, 'test@example.com');
        expect(user.phoneNumber, isNull);
        expect(user.emailVerified, false);
        expect(user.createdAt, now);
        expect(user.lastSignInAt, isNull);
        expect(user.userType, UserType.farmer);
        expect(user.merchantType, isNull);
        expect(user.isProfileComplete, false);
        expect(user.hasSkippedProfileSetup, false);
        expect(user.isAnonymous, false);
      });

      test('should create with all fields populated', () {
        final lastSignIn = DateTime(2026, 1, 16);
        final user = UserModel(
          uid: 'uid2',
          email: 'merchant@example.com',
          phoneNumber: '+267 71234567',
          emailVerified: true,
          createdAt: now,
          lastSignInAt: lastSignIn,
          userType: UserType.merchant,
          merchantType: MerchantType.agriShop,
          isProfileComplete: true,
          hasSkippedProfileSetup: true,
          isAnonymous: false,
        );

        expect(user.uid, 'uid2');
        expect(user.email, 'merchant@example.com');
        expect(user.phoneNumber, '+267 71234567');
        expect(user.emailVerified, true);
        expect(user.lastSignInAt, lastSignIn);
        expect(user.userType, UserType.merchant);
        expect(user.merchantType, MerchantType.agriShop);
        expect(user.isProfileComplete, true);
        expect(user.hasSkippedProfileSetup, true);
      });
    });

    group('fromFirestore', () {
      test('should parse valid data', () {
        final data = {
          'email': 'test@example.com',
          'phoneNumber': '+267 71234567',
          'emailVerified': true,
          'createdAt': Timestamp.fromDate(now),
          'lastSignInAt': Timestamp.fromDate(now),
          'userType': 'farmer',
          'merchantType': null,
          'isProfileComplete': true,
          'hasSkippedProfileSetup': false,
          'isAnonymous': false,
        };

        final user = userModelFromFirestore(data, 'uid1');

        expect(user.uid, 'uid1');
        expect(user.email, 'test@example.com');
        expect(user.phoneNumber, '+267 71234567');
        expect(user.emailVerified, true);
        expect(user.createdAt, now);
        expect(user.lastSignInAt, now);
        expect(user.userType, UserType.farmer);
        expect(user.merchantType, isNull);
        expect(user.isProfileComplete, true);
        expect(user.hasSkippedProfileSetup, false);
        expect(user.isAnonymous, false);
      });

      test('should handle missing optional fields', () {
        final data = {
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'farmer',
        };

        final user = userModelFromFirestore(data, 'uid1');

        expect(user.phoneNumber, isNull);
        expect(user.emailVerified, false);
        expect(user.lastSignInAt, isNull);
        expect(user.merchantType, isNull);
        expect(user.isProfileComplete, false);
        expect(user.hasSkippedProfileSetup, false);
        expect(user.isAnonymous, false);
      });

      test('should fallback to farmer for unknown userType', () {
        final data = {
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'unknownType',
        };

        final user = userModelFromFirestore(data, 'uid1');
        expect(user.userType, UserType.farmer);
      });

      test('should fallback to agriShop for unknown merchantType', () {
        final data = {
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'merchant',
          'merchantType': 'unknownMerchant',
        };

        final user = userModelFromFirestore(data, 'uid1');
        expect(user.merchantType, MerchantType.agriShop);
      });

      test('should default null booleans to false', () {
        final data = {
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'farmer',
          'emailVerified': null,
          'isProfileComplete': null,
          'hasSkippedProfileSetup': null,
          'isAnonymous': null,
        };

        final user = userModelFromFirestore(data, 'uid1');
        expect(user.emailVerified, false);
        expect(user.isProfileComplete, false);
        expect(user.hasSkippedProfileSetup, false);
        expect(user.isAnonymous, false);
      });
    });

    group('toFirestore', () {
      test('should serialize all fields', () {
        final user = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          phoneNumber: '+267 71234567',
          emailVerified: true,
          createdAt: now,
          lastSignInAt: now,
          userType: UserType.merchant,
          merchantType: MerchantType.supermarketVendor,
          isProfileComplete: true,
          hasSkippedProfileSetup: false,
          isAnonymous: false,
        );

        final map = userModelToFirestore(user);

        expect(map['email'], 'test@example.com');
        expect(map['phoneNumber'], '+267 71234567');
        expect(map['emailVerified'], true);
        expect(map['createdAt'], isA<Timestamp>());
        expect((map['createdAt'] as Timestamp).toDate(), now);
        expect(map['lastSignInAt'], isA<Timestamp>());
        expect(map['userType'], 'merchant');
        expect(map['merchantType'], 'supermarketVendor');
        expect(map['isProfileComplete'], true);
        expect(map['hasSkippedProfileSetup'], false);
        expect(map['isAnonymous'], false);
        expect(map['updatedAt'], isA<FieldValue>());
      });

      test('should handle null merchantType', () {
        final user = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );

        final map = userModelToFirestore(user);
        expect(map['merchantType'], isNull);
      });

      test('should handle null lastSignInAt', () {
        final user = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );

        final map = userModelToFirestore(user);
        expect(map['lastSignInAt'], isNull);
      });
    });

    group('copyWith', () {
      final original = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: false,
        createdAt: now,
        userType: UserType.farmer,
      );

      test('should copy with single field changed', () {
        final copy = original.copyWith(email: 'new@example.com');
        expect(copy.email, 'new@example.com');
        expect(copy.uid, original.uid);
        expect(copy.userType, original.userType);
      });

      test('should copy with multiple fields changed', () {
        final copy = original.copyWith(
          email: 'new@example.com',
          userType: UserType.merchant,
          merchantType: MerchantType.agriShop,
          isProfileComplete: true,
        );

        expect(copy.email, 'new@example.com');
        expect(copy.userType, UserType.merchant);
        expect(copy.merchantType, MerchantType.agriShop);
        expect(copy.isProfileComplete, true);
        expect(copy.uid, original.uid);
      });

      test('should return equal object when no args provided', () {
        final copy = original.copyWith();
        expect(copy, equals(original));
      });
    });

    group('Equatable', () {
      test('should be equal when all fields match', () {
        final user1 = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );
        final user2 = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when uid differs', () {
        final user1 = UserModel(
          uid: 'uid1',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );
        final user2 = UserModel(
          uid: 'uid2',
          email: 'test@example.com',
          emailVerified: false,
          createdAt: now,
          userType: UserType.farmer,
        );

        expect(user1, isNot(equals(user2)));
      });
    });
  });
}
