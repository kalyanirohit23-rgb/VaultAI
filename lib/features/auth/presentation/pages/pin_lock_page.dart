import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

class PinLockPage extends ConsumerStatefulWidget {
  const PinLockPage({super.key});

  @override
  ConsumerState<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends ConsumerState<PinLockPage> {
  final _secureStorage = const FlutterSecureStorage();
  String _enteredPin = '';
  String _errorMessage = '';
  int _attemptCount = 0;
  bool _isLocked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pin_outlined, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                'Enter PIN',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your ${AppConstants.pinLength}-digit PIN to unlock',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: AppConstants.pinLength,
                obscureText: true,
                animationType: AnimationType.fade,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: AppColors.primary.withValues(alpha: 0.1),
                  inactiveFillColor: AppColors.grey100,
                  selectedFillColor: AppColors.primary.withValues(alpha: 0.1),
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.grey300,
                  selectedColor: AppColors.primary,
                ),
                onChanged: (value) => _enteredPin = value,
                onCompleted: (pin) => _verifyPin(pin),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              if (_isLocked) ...[
                const SizedBox(height: 16),
                Text(
                  'Too many attempts. Try again in ${AppConstants.pinLockoutMinutes} minutes.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.warning),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPin(String pin) async {
    if (_isLocked) return;

    final storedPin = await _secureStorage.read(key: 'vault_pin');

    if (storedPin == null) {
      // First time - set PIN
      await _secureStorage.write(key: 'vault_pin', value: pin);
      if (mounted) context.go(AppRoutes.home);
      return;
    }

    if (pin == storedPin) {
      if (mounted) context.go(AppRoutes.home);
    } else {
      _attemptCount++;
      setState(() {
        _errorMessage = 'Incorrect PIN. ${AppConstants.maxPinAttempts - _attemptCount} attempts remaining.';
      });

      if (_attemptCount >= AppConstants.maxPinAttempts) {
        setState(() => _isLocked = true);
        // In production, lock for pinLockoutMinutes
      }
    }
  }
}
