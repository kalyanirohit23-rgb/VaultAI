import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Initialize all app dependencies
Future<void> initializeDependencies() async {
  await _initHiveAdapters();
  await _openHiveBoxes();
}

Future<void> _initHiveAdapters() async {
  // Register Hive adapters if needed
}

Future<void> _openHiveBoxes() async {
  await Hive.openBox<dynamic>(AppConstants.settingsBox);
  await Hive.openBox<dynamic>(AppConstants.documentsBox);
  await Hive.openBox<dynamic>(AppConstants.userBox);
  await Hive.openBox<dynamic>(AppConstants.authBox);
}
