import 'package:equatable/equatable.dart';

/// User entity
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.phone,
    this.createdAt,
    this.lastSignIn,
    this.emailVerified = false,
    this.subscriptionTier = 'free',
    this.storageUsed = 0,
    this.documentCount = 0,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastSignIn;
  final bool emailVerified;
  final String subscriptionTier;
  final int storageUsed;
  final int documentCount;

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final words = displayName!.trim().split(' ');
      if (words.length >= 2) {
        return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get isPro => subscriptionTier == 'pro' || subscriptionTier == 'family' || subscriptionTier == 'enterprise';

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? phone,
    DateTime? createdAt,
    DateTime? lastSignIn,
    bool? emailVerified,
    String? subscriptionTier,
    int? storageUsed,
    int? documentCount,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      emailVerified: emailVerified ?? this.emailVerified,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      storageUsed: storageUsed ?? this.storageUsed,
      documentCount: documentCount ?? this.documentCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        phone,
        createdAt,
        lastSignIn,
        emailVerified,
        subscriptionTier,
        storageUsed,
        documentCount,
      ];
}
