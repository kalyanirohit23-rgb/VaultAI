import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.brightness_6_outlined,
                label: 'Theme',
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (modes) => ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(modes.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Security',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint, color: AppColors.primary),
                title: const Text('Biometric Lock'),
                subtitle: const Text('Use fingerprint or face to unlock'),
                value: settings.biometricEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleBiometric(v),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.pin_outlined, color: AppColors.primary),
                title: const Text('PIN Lock'),
                subtitle: const Text('Use 6-digit PIN to unlock'),
                value: settings.pinEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).togglePin(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive expiry alerts and reminders'),
                value: settings.notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleNotifications(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Backup',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.backup_outlined, color: AppColors.primary),
                title: const Text('Auto Backup'),
                subtitle: const Text('Automatically backup to cloud'),
                value: settings.autoBackupEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleAutoBackup(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.grey600),
                title: const Text('Version'),
                trailing: const Text('1.0.0', style: TextStyle(color: AppColors.grey500)),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.grey600),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.grey600),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.grey500,
                  letterSpacing: 1,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });
  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey600),
      title: Text(label),
      trailing: trailing,
    );
  }
}
