import 'dart:io';

import 'package:intl/intl.dart';

/// Date/time utilities
class DateUtils {
  DateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return formatDate(date);
    }
  }

  static String formatExpiryStatus(DateTime? expiryDate) {
    if (expiryDate == null) return '';
    final now = DateTime.now();
    final diff = expiryDate.difference(now);

    if (diff.isNegative) {
      return 'Expired ${formatDate(expiryDate)}';
    } else if (diff.inDays <= 7) {
      return 'Expires in ${diff.inDays} days';
    } else if (diff.inDays <= 30) {
      return 'Expires in ${diff.inDays} days';
    } else if (diff.inDays <= 90) {
      return 'Expires in ${(diff.inDays / 30).round()} months';
    } else {
      return 'Valid until ${formatDate(expiryDate)}';
    }
  }

  static bool isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    return expiryDate.isBefore(DateTime.now());
  }

  static bool isExpiringSoon(DateTime? expiryDate, {int daysThreshold = 90}) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final diff = expiryDate.difference(now);
    return !diff.isNegative && diff.inDays <= daysThreshold;
  }

  static String getDaysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return '';
    final diff = expiryDate.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    return '${diff.inDays} days';
  }
}

/// File utilities
class FileUtils {
  FileUtils._();

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }

  static bool isPdf(String filename) {
    return getFileExtension(filename) == 'pdf';
  }

  static bool isImage(String filename) {
    final ext = getFileExtension(filename);
    return ['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(ext);
  }

  static String getMimeType(String filename) {
    final ext = getFileExtension(filename);
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }

  static Future<int> getFileSize(String path) async {
    final file = File(path);
    return await file.length();
  }
}

/// String utilities
class StringUtils {
  StringUtils._();

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isStrongPassword(String password) {
    // Min 8 chars, at least one uppercase, one lowercase, one number
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}*@$domain';
    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  static String generateInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

/// Storage utilities
class StorageUtils {
  StorageUtils._();

  static double bytesToMb(int bytes) => bytes / (1024 * 1024);

  static double bytesToGb(int bytes) => bytes / (1024 * 1024 * 1024);

  static String formatStorageUsed(int usedBytes, int totalBytes) {
    return '${FileUtils.formatFileSize(usedBytes)} / ${FileUtils.formatFileSize(totalBytes)}';
  }

  static double getUsagePercentage(int usedBytes, int totalBytes) {
    if (totalBytes == 0) return 0;
    return (usedBytes / totalBytes).clamp(0.0, 1.0);
  }
}
