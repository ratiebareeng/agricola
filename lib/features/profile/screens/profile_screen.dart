import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/screens/farmer_profile_screen.dart';
import 'package:agricola/features/profile/screens/merchant_profile_screen.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read from actual user data in Firestore, not cached profile setup data
    final user = ref.watch(currentUserProvider);

    // If user data is not loaded yet, default to merchant screen
    if (user == null) {
      return const MerchantProfileScreen();
    }

    if (user.userType == UserType.farmer) {
      return const FarmerProfileScreen();
    } else {
      return const MerchantProfileScreen();
    }
  }
}
