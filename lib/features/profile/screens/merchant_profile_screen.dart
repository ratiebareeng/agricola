import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/utils/url_utils.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/language_select_content.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/domain/models/displayable_profile.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:agricola/features/reports/screens/reports_screen.dart';
import 'package:agricola/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MerchantProfileScreen extends ConsumerStatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  ConsumerState<MerchantProfileScreen> createState() =>
      _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends ConsumerState<MerchantProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final displayableProfile = profileState.displayableProfile;

    // Show loading spinner only on initial load
    if (profileState.isLoading && displayableProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error if we couldn't load any profile data
    if (displayableProfile == null) {
      return _buildErrorScreen(context, profileState.errorMessage);
    }

    // Handle both minimal and complete profiles
    return switch (displayableProfile) {
      MinimalProfile() => _buildMinimalProfileScreen(
        context,
        ref,
        displayableProfile,
      ),
      CompleteMerchantProfile() => _buildCompleteProfileScreen(
        context,
        ref,
        displayableProfile,
      ),
      CompleteFarmerProfile() => _buildErrorScreen(context, null),
    };
  }

  @override
  void initState() {
    super.initState();

    // Always try to load profile (will fallback to minimal profile if needed)
    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref
            .read(profileControllerProvider.notifier)
            .loadProfile(userId: user.uid);
      }
    });
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.green, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(
    BuildContext context,
    WidgetRef ref,
    MinimalProfile profile,
  ) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('profile_information', currentLang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_outlined,
            t('email', currentLang),
            profile.email,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            t('phone', currentLang),
            profile.phoneNumber ?? 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsCard(
    BuildContext context,
    WidgetRef ref,
    MerchantProfileModel profile,
  ) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t('business_details', currentLang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _navigateToEditProfile(context, profile),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(t('edit', currentLang)),
                style: TextButton.styleFrom(foregroundColor: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.business,
            t('business_name', currentLang),
            profile.businessName,
          ),
          const Divider(height: 24),
          _buildProductsSection(context, ref, profile),
        ],
      ),
    );
  }


  Widget _buildCompleteProfileScreen(
    BuildContext context,
    WidgetRef ref,
    CompleteMerchantProfile profile,
  ) {
    final merchantProfile = profile.merchantData;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider.notifier)
              .loadProfile(userId: profile.userId, forceRefresh: true);
        },
        child: CustomScrollView(
          slivers: [
            _buildProfileHeader(context, ref, profile),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfoCard(context, ref, profile),
                    const SizedBox(height: 16),
                    _buildBusinessDetailsCard(context, ref, merchantProfile),
                    const SizedBox(height: 16),
                    _buildQuickActionsCard(context, ref),
                    const SizedBox(height: 16),
                    _buildSettingsSection(context, ref),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String? errorMessage) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Failed to load profile',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: AgriStadiumButton(
                onPressed: () {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref
                        .read(profileControllerProvider.notifier)
                        .loadProfile(userId: user.uid);
                  }
                },
                label: 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalProfileScreen(
    BuildContext context,
    WidgetRef ref,
    MinimalProfile profile,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildProfileHeader(context, ref, profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileCompletionBanner(context, ref),
                  const SizedBox(height: 16),
                  _buildBasicInfoCard(context, ref, profile),
                  const SizedBox(height: 16),
                  _buildSettingsSection(context, ref),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(
    BuildContext context,
    WidgetRef ref,
    MerchantProfileModel profile,
  ) {
    final currentLang = ref.watch(languageProvider);
    final isAgriShop = profile.merchantType == MerchantType.agriShop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_cart, size: 20, color: AppColors.green),
            const SizedBox(width: 12),
            Text(
              isAgriShop
                  ? t('what_do_you_sell', currentLang)
                  : t('products_bought', currentLang),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (profile.productsOffered.isEmpty)
          const Text(
            'Not set',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.productsOffered.map((product) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.green.withAlpha(30)),
                ),
                child: Text(
                  product,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProfileCompletionBanner(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green, AppColors.green.withAlpha(80)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Add your business details to unlock the full Agricola experience. Manage inventory, track sales, and connect with suppliers.',
            style: TextStyle(color: Colors.white.withAlpha(90), fontSize: 14),
          ),
          const SizedBox(height: 16),
          AgriStadiumButton(
            onPressed: () {
              if (user == null) return;

              // Determine the user type string for the route
              String userTypeParam;
              if (user.merchantType == MerchantType.agriShop) {
                userTypeParam = 'agriShop';
              } else if (user.merchantType ==
                  MerchantType.supermarketVendor) {
                userTypeParam = 'supermarketVendor';
              } else {
                userTypeParam =
                    'agriShop'; // Default to agriShop for other merchant types
              }

              context.push('/profile-setup?type=$userTypeParam');
            },
            label: 'Complete Profile',
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    DisplayableProfile profile,
  ) {
    final currentLang = ref.watch(languageProvider);

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.green,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.green, AppColors.green.withAlpha(80)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              GestureDetector(
                onTap: profile is CompleteMerchantProfile
                    ? () =>
                          _navigateToEditProfile(context, profile.merchantData)
                    : null,
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: isNetworkUrl(profile.photoUrl)
                            ? DecorationImage(
                                image: NetworkImage(profile.photoUrl!),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              )
                            : null,
                        color: Colors.white.withAlpha(30),
                      ),
                      child: profile.photoUrl == null
                          ? const Icon(
                              Icons.store,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (profile is CompleteMerchantProfile)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.green,
                              width: 2,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.camera_alt,
                              color: AppColors.green,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.merchantType == MerchantType.agriShop
                    ? t('agri_shop', currentLang)
                    : profile.merchantType == MerchantType.supermarketVendor
                    ? t('supermarket_vendor', currentLang)
                    : t('merchant', currentLang),
                style: TextStyle(
                  color: Colors.white.withAlpha(90),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showLanguageDialog(context, ref),
          icon: const Icon(Icons.language, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(
    BuildContext context,
    WidgetRef ref,
    CompleteMerchantProfile profile,
  ) {
    final currentLang = ref.watch(languageProvider);
    final merchantProfile = profile.merchantData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t('profile_information', currentLang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    _navigateToEditProfile(context, merchantProfile),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(t('edit', currentLang)),
                style: TextButton.styleFrom(foregroundColor: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_outlined,
            t('email', currentLang),
            profile.email,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            t('phone', currentLang),
            profile.phoneNumber ?? 'Not set',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            t('location', currentLang),
            merchantProfile.displayLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('quick_actions', currentLang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            Icons.bar_chart,
            t('business_stats', currentLang),
            t('view_reports_desc', currentLang),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MerchantReportsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            t('settings', currentLang),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.green),
            title: Text(
              t('settings', currentLang),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile(
    BuildContext context,
    MerchantProfileModel profile,
  ) {
    context.push('/profile/edit-merchant', extra: profile);
  }


  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final notifier = ref.read(languageProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('select_language', currentLang)),
        content: LanguageSelectContent(
          currentLang: currentLang,
          notifier: notifier,
        ),
      ),
    );
  }

}
