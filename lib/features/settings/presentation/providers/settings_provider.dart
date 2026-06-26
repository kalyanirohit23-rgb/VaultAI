import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.notificationsEnabled = true,
    this.autoBackupEnabled = true,
  });

  final ThemeMode themeMode;
  final String language;
  final bool biometricEnabled;
  final bool pinEnabled;
  final bool notificationsEnabled;
  final bool autoBackupEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? notificationsEnabled,
    bool? autoBackupEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Box<dynamic> get _box => Hive.box<dynamic>(AppConstants.settingsBox);

  void _loadSettings() {
    final themeModeIndex = _box.get('themeMode', defaultValue: 0) as int;
    state = AppSettings(
      themeMode: ThemeMode.values[themeModeIndex.clamp(0, 2)],
      language: _box.get('language', defaultValue: 'en') as String,
      biometricEnabled: _box.get('biometricEnabled', defaultValue: false) as bool,
      pinEnabled: _box.get('pinEnabled', defaultValue: false) as bool,
      notificationsEnabled: _box.get('notificationsEnabled', defaultValue: true) as bool,
      autoBackupEnabled: _box.get('autoBackupEnabled', defaultValue: true) as bool,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> toggleBiometric(bool enabled) async {
    await _box.put('biometricEnabled', enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<void> togglePin(bool enabled) async {
    await _box.put('pinEnabled', enabled);
    state = state.copyWith(pinEnabled: enabled);
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _box.put('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    await _box.put('autoBackupEnabled', enabled);
    state = state.copyWith(autoBackupEnabled: enabled);
  }

  Future<void> setLanguage(String lang) async {
    await _box.put('language', lang);
    state = state.copyWith(language: lang);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
