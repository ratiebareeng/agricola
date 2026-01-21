import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile/providers/profile_state_notifier.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/auth/models/user_model_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProfileStateNotifier mockProfileNotifier;
  late MockAuthController mockAuthController;
  late ProviderContainer container;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(
      FarmerProfileModel(
        id: '',
        userId: '',
        village: '',
        primaryCrops: [],
        farmSize: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      MerchantProfileModel(
        id: '',
        userId: '',
        merchantType: MerchantType.agriShop,
        businessName: '',
        location: '',
        productsOffered: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() async {
    // Mock SharedPreferences with empty state for each test
    SharedPreferences.setMockInitialValues({});

    mockProfileNotifier = MockProfileStateNotifier();
    mockAuthController = MockAuthController();

    container = ProviderContainer(
      overrides: [
        profileControllerProvider.overrideWith((ref) => mockProfileNotifier),
        authControllerProvider.overrideWith((ref) => mockAuthController),
        currentUserProvider.overrideWithValue(testUser),
        // Override profileSetupProvider to not call loadProfile() on init
        profileSetupProvider.overrideWith((ref) {
          return ProfileSetupNotifier(ref); // Don't call ..loadProfile()
        }),
      ],
    );

    // No need to wait since we're not calling loadProfile anymore
  });

  tearDown(() async {
    container.dispose();
    // Wait for disposal to complete
    await Future.delayed(Duration.zero);
  });

  group('ProfileSetupNotifier.completeSetup - Farmer', () {
    test(
      'should create farmer profile successfully when data is valid',
      () async {
        // Arrange
        final notifier = container.read(profileSetupProvider.notifier);

        // Set up farmer profile data
        notifier.startNewProfileSetup(UserType.farmer, null);
        notifier.updateVillage('Test Village');
        notifier.toggleCrop('Maize');
        notifier.toggleCrop('Sorghum');
        notifier.updateFarmSize('Small (< 5 acres)');
        await Future.delayed(const Duration(milliseconds: 200));

        when(
          () => mockProfileNotifier.createFarmerProfile(
            profile: any(named: 'profile'),
          ),
        ).thenAnswer((_) async => true);

        when(
          () => mockAuthController.markProfileAsComplete(),
        ).thenAnswer((_) async => {});

        // Act
        final success = await notifier.completeSetup();

        // Assert
        expect(success, true);
        verify(
          () => mockProfileNotifier.createFarmerProfile(
            profile: any(named: 'profile'),
          ),
        ).called(1);
        verify(() => mockAuthController.markProfileAsComplete()).called(1);
      },
    );

    test('should fail when village is empty', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      // Don't set village
      notifier.toggleCrop('Maize');
      notifier.updateFarmSize('Small (< 5 acres)');
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      );
      verifyNever(() => mockAuthController.markProfileAsComplete());
    });

    test('should fail when no crops selected', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      notifier.updateVillage('Test Village');
      // Don't select any crops
      notifier.updateFarmSize('Small (< 5 acres)');
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      );
    });

    test('should fail when farm size is empty', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      notifier.updateVillage('Test Village');
      notifier.toggleCrop('Maize');
      await Future.delayed(const Duration(milliseconds: 100));
      // Don't set farm size

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      );
    });

    test('should handle backend failure gracefully', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      notifier.updateVillage('Test Village');
      notifier.toggleCrop('Maize');
      notifier.updateFarmSize('Small (< 5 acres)');
      await Future.delayed(const Duration(milliseconds: 200));

      when(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((_) async => false); // Backend failure

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verify(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      ).called(1);
      verifyNever(() => mockAuthController.markProfileAsComplete());
    });

    test('should include custom village when provided', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      notifier.updateVillage('Other');
      notifier.updateCustomVillage('My Custom Village');
      notifier.toggleCrop('Maize');
      notifier.updateFarmSize('Small (< 5 acres)');
      await Future.delayed(const Duration(milliseconds: 200));

      FarmerProfileModel? capturedProfile;
      when(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((invocation) async {
        capturedProfile =
            invocation.namedArguments[const Symbol('profile')]
                as FarmerProfileModel;
        return true;
      });

      when(
        () => mockAuthController.markProfileAsComplete(),
      ).thenAnswer((_) async => {});

      // Act
      await notifier.completeSetup();

      // Assert
      expect(capturedProfile, isNotNull);
      expect(capturedProfile!.customVillage, 'My Custom Village');
    });

    test('should include photo path when provided', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      notifier.updateVillage('Test Village');
      notifier.toggleCrop('Maize');
      notifier.updateFarmSize('Small (< 5 acres)');
      notifier.setPhoto('/path/to/photo.jpg');
      await Future.delayed(const Duration(milliseconds: 200));

      FarmerProfileModel? capturedProfile;
      when(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((invocation) async {
        capturedProfile =
            invocation.namedArguments[const Symbol('profile')]
                as FarmerProfileModel;
        return true;
      });

      when(
        () => mockAuthController.markProfileAsComplete(),
      ).thenAnswer((_) async => {});

      // Act
      await notifier.completeSetup();

      // Assert
      expect(capturedProfile, isNotNull);
      expect(capturedProfile!.photoUrl, '/path/to/photo.jpg');
    });
  });

  group('ProfileSetupNotifier.completeSetup - Merchant', () {
    test(
      'should create merchant profile successfully when data is valid',
      () async {
        // Arrange
        final notifier = container.read(profileSetupProvider.notifier);

        notifier.startNewProfileSetup(UserType.merchant, MerchantType.agriShop);
        notifier.updateBusinessName('My Agri Shop');
        notifier.updateLocation('Gaborone');
        notifier.toggleProduct('Seeds');
        notifier.toggleProduct('Fertilizers');
        await Future.delayed(const Duration(milliseconds: 200));

        when(
          () => mockProfileNotifier.createMerchantProfile(
            profile: any(named: 'profile'),
          ),
        ).thenAnswer((_) async => true);

        when(
          () => mockAuthController.markProfileAsComplete(),
        ).thenAnswer((_) async => {});

        // Act
        final success = await notifier.completeSetup();

        // Assert
        expect(success, true);
        verify(
          () => mockProfileNotifier.createMerchantProfile(
            profile: any(named: 'profile'),
          ),
        ).called(1);
        verify(() => mockAuthController.markProfileAsComplete()).called(1);
      },
    );

    test('should fail when business name is empty', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.merchant, MerchantType.agriShop);
      // Don't set business name
      notifier.updateLocation('Gaborone');
      notifier.toggleProduct('Seeds');
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      );
    });

    test('should fail when location is empty', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.merchant, MerchantType.agriShop);
      notifier.updateBusinessName('My Agri Shop');
      // Don't set location
      notifier.toggleProduct('Seeds');
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      );
    });

    test('should fail when no products selected', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.merchant, MerchantType.agriShop);
      notifier.updateBusinessName('My Agri Shop');
      notifier.updateLocation('Gaborone');
      await Future.delayed(const Duration(milliseconds: 100));
      // Don't select any products

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      );
    });

    test('should fail when merchant type is not set', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      // Start with farmer type (no merchant type)
      notifier.startNewProfileSetup(UserType.farmer, null);
      // Then manually change to merchant without setting merchant type
      notifier.setUserType(UserType.merchant);
      notifier.updateBusinessName('My Agri Shop');
      notifier.updateLocation('Gaborone');
      notifier.toggleProduct('Seeds');
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      );
    });

    test('should handle backend failure gracefully', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.merchant, MerchantType.agriShop);
      notifier.updateBusinessName('My Agri Shop');
      notifier.updateLocation('Gaborone');
      notifier.toggleProduct('Seeds');
      await Future.delayed(const Duration(milliseconds: 200));

      when(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((_) async => false); // Backend failure

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verify(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      ).called(1);
      verifyNever(() => mockAuthController.markProfileAsComplete());
    });

    test('should pass correct merchant type to profile', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(
        UserType.merchant,
        MerchantType.feedSupplier,
      );
      notifier.updateBusinessName('Feed Supplier Co');
      notifier.updateLocation('Gaborone');
      notifier.toggleProduct('Animal Feed');
      await Future.delayed(const Duration(milliseconds: 200));

      MerchantProfileModel? capturedProfile;
      when(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((invocation) async {
        capturedProfile =
            invocation.namedArguments[const Symbol('profile')]
                as MerchantProfileModel;
        return true;
      });

      when(
        () => mockAuthController.markProfileAsComplete(),
      ).thenAnswer((_) async => {});

      // Act
      await notifier.completeSetup();

      // Assert
      expect(capturedProfile, isNotNull);
      expect(capturedProfile!.merchantType, MerchantType.feedSupplier);
    });

    test('should include custom location when provided', () async {
      // Arrange
      final notifier = container.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.merchant, MerchantType.agriShop);
      notifier.updateBusinessName('My Agri Shop');
      notifier.updateLocation('Other');
      notifier.updateCustomVillage('My Custom Location');
      notifier.toggleProduct('Seeds');
      await Future.delayed(const Duration(milliseconds: 100));

      MerchantProfileModel? capturedProfile;
      when(
        () => mockProfileNotifier.createMerchantProfile(
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((invocation) async {
        capturedProfile =
            invocation.namedArguments[const Symbol('profile')]
                as MerchantProfileModel;
        return true;
      });

      when(
        () => mockAuthController.markProfileAsComplete(),
      ).thenAnswer((_) async => {});

      // Act
      await notifier.completeSetup();

      // Assert
      expect(capturedProfile, isNotNull);
      expect(capturedProfile!.customLocation, 'My Custom Location');
    });
  });

  group('ProfileSetupNotifier.completeSetup - Edge Cases', () {
    test('should return false when no user is signed in', () async {
      // Arrange
      final testContainer = ProviderContainer(
        overrides: [
          profileControllerProvider.overrideWith((ref) => mockProfileNotifier),
          authControllerProvider.overrideWith((ref) => mockAuthController),
          currentUserProvider.overrideWithValue(null), // No user
        ],
      );

      final notifier = testContainer.read(profileSetupProvider.notifier);

      notifier.startNewProfileSetup(UserType.farmer, null);
      notifier.updateVillage('Test Village');
      notifier.toggleCrop('Maize');
      notifier.updateFarmSize('Small (< 5 acres)');

      // Wait for async save operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final success = await notifier.completeSetup();

      // Assert
      expect(success, false);
      verifyNever(
        () => mockProfileNotifier.createFarmerProfile(
          profile: any(named: 'profile'),
        ),
      );
      verifyNever(() => mockAuthController.markProfileAsComplete());

      testContainer.dispose();
      await Future.delayed(const Duration(milliseconds: 100));
    });
  });
}

class MockAuthController extends Mock implements AuthController {}

// Mocks
class MockProfileStateNotifier extends Mock implements ProfileStateNotifier {}
