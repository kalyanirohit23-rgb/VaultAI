import 'package:flutter_test/flutter_test.dart';
import 'package:vault_ai/core/utils/app_utils.dart';
import 'package:vault_ai/features/auth/domain/entities/user_entity.dart';

void main() {
  group('StringUtils', () {
    test('isValidEmail returns true for valid email', () {
      expect(StringUtils.isValidEmail('test@example.com'), isTrue);
      expect(StringUtils.isValidEmail('user.name+tag@example.co.uk'), isTrue);
    });

    test('isValidEmail returns false for invalid email', () {
      expect(StringUtils.isValidEmail('not-an-email'), isFalse);
      expect(StringUtils.isValidEmail('missing@domain'), isFalse);
      expect(StringUtils.isValidEmail(''), isFalse);
    });

    test('isStrongPassword validates correctly', () {
      expect(StringUtils.isStrongPassword('Abc12345'), isTrue);
      expect(StringUtils.isStrongPassword('weakpass'), isFalse);
      expect(StringUtils.isStrongPassword('SHORT1'), isFalse);
      expect(StringUtils.isStrongPassword('alllowercase1'), isFalse);
    });

    test('generateInitials from full name', () {
      expect(StringUtils.generateInitials('John Doe'), equals('JD'));
      expect(StringUtils.generateInitials('Alice'), equals('A'));
      expect(StringUtils.generateInitials('John Michael Doe'), equals('JD'));
    });

    test('maskEmail masks correctly', () {
      final masked = StringUtils.maskEmail('john@example.com');
      expect(masked, equals('jo**@example.com'));
    });
  });

  group('UserEntity', () {
    test('isPro returns true for pro subscription', () {
      const user = UserEntity(
        id: '1',
        email: 'test@example.com',
        subscriptionTier: 'pro',
      );
      expect(user.isPro, isTrue);
    });

    test('isPro returns false for free subscription', () {
      const user = UserEntity(
        id: '1',
        email: 'test@example.com',
        subscriptionTier: 'free',
      );
      expect(user.isPro, isFalse);
    });

    test('initials generated from display name', () {
      const user = UserEntity(
        id: '1',
        email: 'test@example.com',
        displayName: 'Jane Doe',
      );
      expect(user.initials, equals('JD'));
    });

    test('initials from email when no display name', () {
      const user = UserEntity(
        id: '1',
        email: 'alice@example.com',
      );
      expect(user.initials, equals('A'));
    });
  });

  group('DateUtils', () {
    test('isExpired returns true for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      expect(DateUtils.isExpired(pastDate), isTrue);
    });

    test('isExpired returns false for future dates', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      expect(DateUtils.isExpired(futureDate), isFalse);
    });

    test('isExpiringSoon returns true within threshold', () {
      final soonDate = DateTime.now().add(const Duration(days: 30));
      expect(DateUtils.isExpiringSoon(soonDate, daysThreshold: 90), isTrue);
    });

    test('isExpiringSoon returns false for distant date', () {
      final distantDate = DateTime.now().add(const Duration(days: 365));
      expect(DateUtils.isExpiringSoon(distantDate, daysThreshold: 90), isFalse);
    });
  });

  group('FileUtils', () {
    test('formatFileSize formats bytes correctly', () {
      expect(FileUtils.formatFileSize(500), equals('500 B'));
      expect(FileUtils.formatFileSize(1024), equals('1.0 KB'));
      expect(FileUtils.formatFileSize(1024 * 1024), equals('1.0 MB'));
    });

    test('isPdf returns true for PDF files', () {
      expect(FileUtils.isPdf('document.pdf'), isTrue);
      expect(FileUtils.isPdf('image.jpg'), isFalse);
    });

    test('isImage returns true for image files', () {
      expect(FileUtils.isImage('photo.jpg'), isTrue);
      expect(FileUtils.isImage('photo.PNG'), isTrue);
      expect(FileUtils.isImage('document.pdf'), isFalse);
    });
  });
}
