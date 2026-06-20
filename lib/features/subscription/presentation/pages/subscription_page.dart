import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'pro';

  final List<_SubscriptionPlan> _plans = const [
    _SubscriptionPlan(
      id: 'free',
      name: 'Free',
      price: '\$0',
      period: 'forever',
      color: AppColors.grey500,
      features: [
        '100 documents',
        'Basic OCR',
        'Basic reminders',
        'Cloud backup',
      ],
    ),
    _SubscriptionPlan(
      id: 'pro',
      name: 'Pro',
      price: '\$4.99',
      period: '/month',
      color: AppColors.primary,
      isPopular: true,
      features: [
        'Unlimited documents',
        'AI Search',
        'AI Chat Assistant',
        'Unlimited OCR',
        'Smart reminders',
        'Priority support',
      ],
    ),
    _SubscriptionPlan(
      id: 'family',
      name: 'Family',
      price: '\$9.99',
      period: '/month',
      color: AppColors.secondary,
      features: [
        'Up to 6 members',
        'Shared vault',
        'Shared reminders',
        'All Pro features',
        'Family dashboard',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Upgrade VaultAI', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Unlock AI-powered features and unlimited storage',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _plans
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plan,
                        isSelected: _selectedPlan == plan.id,
                        onTap: () => setState(() => _selectedPlan = plan.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Subscribing to ${_selectedPlan.toUpperCase()} plan...'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(_selectedPlan == 'free' ? 'Start Free' : 'Subscribe Now'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cancel anytime. Secure payment.',
                  style: TextStyle(color: AppColors.grey500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlan {
  const _SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String price;
  final String period;
  final Color color;
  final List<String> features;
  final bool isPopular;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final _SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? plan.color.withValues(alpha: 0.05)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? plan.color : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan.name,
                    style: TextStyle(
                      color: plan.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (plan.isPopular) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⭐ Popular',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      plan.price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: plan.color,
                      ),
                    ),
                    Text(
                      plan.period,
                      style: const TextStyle(
                        color: AppColors.grey500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: plan.color),
                    const SizedBox(width: 8),
                    Text(f, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
