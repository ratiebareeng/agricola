import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideWidget({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: AppColors.green),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.mediumGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final slides = _getSlides(currentLang);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  return OnboardingSlideWidget(slide: slides[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.green
                              : AppColors.lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        Expanded(
                          child: AppSecondaryButton(
                            label: t('back', currentLang),
                            onTap: _previousPage,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: AppPrimaryButton(
                          label: _currentPage == slides.length - 1
                              ? t('get_started', currentLang)
                              : t('next', currentLang),
                          onTap: () => _nextPage(slides.length),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_currentPage < slides.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          slides.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        t('skip', currentLang),
                        style: const TextStyle(
                          color: AppColors.mediumGray,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48), // Placeholder for alignment
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingSlide> _getSlides(AppLanguage lang) {
    return [
      OnboardingSlide(
        title: t('onboarding_1_title', lang),
        description: t('onboarding_1_desc', lang),
        icon: Icons.grass,
      ),
      OnboardingSlide(
        title: t('onboarding_2_title', lang),
        description: t('onboarding_2_desc', lang),
        icon: Icons.inventory_2,
      ),
      OnboardingSlide(
        title: t('onboarding_3_title', lang),
        description: t('onboarding_3_desc', lang),
        icon: Icons.analytics,
      ),
      OnboardingSlide(
        title: t('onboarding_4_title', lang),
        description: t('onboarding_4_desc', lang),
        icon: Icons.wifi_off,
      ),
    ];
  }

  void _nextPage(int totalSlides) {
    if (_currentPage < totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to next screen (e.g., Login or Dashboard)
      // For MVP prototype, we might just stay here or go to a dummy dashboard
      // context.go('/dashboard');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
