import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/biometric_lock_page.dart';
import '../../features/auth/presentation/pages/pin_lock_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/documents/presentation/pages/document_detail_page.dart';
import '../../features/documents/presentation/pages/document_upload_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/ai/presentation/pages/ai_assistant_page.dart';
import '../../features/ai/presentation/pages/ai_search_page.dart';
import '../../features/reminders/presentation/pages/reminders_page.dart';
import '../../features/family/presentation/pages/family_vault_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../shared/widgets/main_shell.dart';

part 'app_router.g.dart';

/// App route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String biometricLock = '/biometric-lock';
  static const String pinLock = '/pin-lock';
  static const String home = '/home';
  static const String documents = '/documents';
  static const String documentDetail = '/documents/:id';
  static const String documentUpload = '/documents/upload';
  static const String scanner = '/scanner';
  static const String aiAssistant = '/ai-assistant';
  static const String aiSearch = '/ai-search';
  static const String reminders = '/reminders';
  static const String familyVault = '/family-vault';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = Supabase.instance.client.auth.currentSession;

  return GoRouter(
    initialLocation: authState != null ? AppRoutes.home : AppRoutes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.biometricLock,
        builder: (context, state) => const BiometricLockPage(),
      ),
      GoRoute(
        path: AppRoutes.pinLock,
        builder: (context, state) => const PinLockPage(),
      ),
      GoRoute(
        path: AppRoutes.documentUpload,
        builder: (context, state) => const DocumentUploadPage(),
      ),
      GoRoute(
        path: AppRoutes.scanner,
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (context, state) => const AiAssistantPage(),
      ),
      GoRoute(
        path: AppRoutes.aiSearch,
        builder: (context, state) => const AiSearchPage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.documents,
            builder: (context, state) => const DocumentsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => DocumentDetailPage(
                  documentId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.reminders,
            builder: (context, state) => const RemindersPage(),
          ),
          GoRoute(
            path: AppRoutes.familyVault,
            builder: (context, state) => const FamilyVaultPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
