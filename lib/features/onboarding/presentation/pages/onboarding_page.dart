import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      emoji: '🔐',
      title: 'Secure Document Vault',
      description:
          'Store all your important documents in one ultra-secure, encrypted vault. Bank-grade security keeps your files safe.',
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    ),
    OnboardingData(
      emoji: '🤖',
      title: 'AI-Powered Organization',
      description:
          'Our AI automatically reads, categorizes, and organizes your documents. Never search for a document again.',
      gradient: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    ),
    OnboardingData(
      emoji: '🔍',
      title: 'Smart AI Search',
      description:
          'Ask in plain language: "Show my passport" or "When does my licence expire?" and get instant answers.',
      gradient: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    OnboardingData(
      emoji: '⏰',
      title: 'Smart Reminders',
      description:
          'Never miss an expiry date. Get alerts for passport renewals, insurance deadlines, and more.',
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
    ),
    OnboardingData(
      emoji: '☁️',
      title: 'Sync Everywhere',
      description:
          'Access your documents on any device. Everything stays in sync securely via the cloud.',
      gradient: [Color(0xFFF59E0B), Color(0xFFF97316)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return OnboardingPageView(data: _pages[index]);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
      child: Column(
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.white.withValues(alpha: 0.4),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    context.go(AppRoutes.login);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
