/// App-wide constants for VaultAI
class AppConstants {
  AppConstants._();

  static const String appName = 'VaultAI';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Supabase table names
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String documentsTable = 'documents';
  static const String categoriesTable = 'categories';
  static const String foldersTable = 'folders';
  static const String tagsTable = 'tags';
  static const String documentTagsTable = 'document_tags';
  static const String remindersTable = 'reminders';
  static const String aiMetadataTable = 'ai_metadata';
  static const String subscriptionsTable = 'subscriptions';
  static const String activityLogsTable = 'activity_logs';
  static const String sharedDocumentsTable = 'shared_documents';
  static const String familyGroupsTable = 'family_groups';
  static const String notificationsTable = 'notifications';
  static const String devicesTable = 'devices';

  // Supabase storage buckets
  static const String documentsBucket = 'documents';
  static const String profilesBucket = 'profiles';
  static const String thumbnailsBucket = 'thumbnails';

  // Hive box names
  static const String settingsBox = 'settings';
  static const String documentsBox = 'cached_documents';
  static const String userBox = 'user_data';
  static const String authBox = 'auth_data';

  // Pagination
  static const int pageSize = 20;
  static const int searchPageSize = 10;

  // File limits
  static const int maxFileSizeMb = 50;
  static const int maxFileSizeBytes = maxFileSizeMb * 1024 * 1024;
  static const int freeDocumentLimit = 100;
  static const int maxImageCompressionQuality = 85;

  // Session & security
  static const int sessionTimeoutMinutes = 30;
  static const int pinLength = 6;
  static const int maxPinAttempts = 5;
  static const int pinLockoutMinutes = 5;

  // Reminder intervals (days before expiry)
  static const List<int> reminderIntervals = [90, 30, 7, 1];

  // AI confidence threshold
  static const double aiConfidenceThreshold = 0.7;

  // Supported file types
  static const List<String> supportedFileTypes = ['pdf', 'jpg', 'jpeg', 'png', 'heic'];

  // Document categories
  static const List<String> documentCategories = [
    'passport',
    'aadhaar',
    'pan',
    'driving_licence',
    'vehicle_rc',
    'insurance',
    'bank_statement',
    'medical',
    'education',
    'property',
    'employment',
    'bills',
    'receipts',
    'warranties',
    'travel',
    'tax',
    'investments',
    'other',
  ];

  // Category display names
  static const Map<String, String> categoryDisplayNames = {
    'passport': 'Passport',
    'aadhaar': 'Aadhaar',
    'pan': 'PAN Card',
    'driving_licence': 'Driving Licence',
    'vehicle_rc': 'Vehicle RC',
    'insurance': 'Insurance',
    'bank_statement': 'Bank Statement',
    'medical': 'Medical Records',
    'education': 'Education',
    'property': 'Property',
    'employment': 'Employment',
    'bills': 'Bills',
    'receipts': 'Receipts',
    'warranties': 'Warranties',
    'travel': 'Travel',
    'tax': 'Tax',
    'investments': 'Investments',
    'other': 'Other',
  };

  // Category icons
  static const Map<String, String> categoryIcons = {
    'passport': '🛂',
    'aadhaar': '🪪',
    'pan': '💳',
    'driving_licence': '🚗',
    'vehicle_rc': '🚙',
    'insurance': '🛡️',
    'bank_statement': '🏦',
    'medical': '🏥',
    'education': '🎓',
    'property': '🏠',
    'employment': '💼',
    'bills': '📄',
    'receipts': '🧾',
    'warranties': '📦',
    'travel': '✈️',
    'tax': '💰',
    'investments': '📈',
    'other': '📁',
  };
}
