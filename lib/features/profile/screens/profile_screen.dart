import 'package:agricola/features/profile/screens/farmer_profile_screen.dart';
import 'package:agricola/features/profile/screens/merchant_profile_screen.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileSetupProvider);

    if (profileState.userType == UserType.farmer) {
      return const FarmerProfileScreen();
    } else {
      return const MerchantProfileScreen();
    }
  }
}
