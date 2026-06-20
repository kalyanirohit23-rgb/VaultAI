import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

/// Data model for User, extends UserEntity with Supabase mapping
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.phone,
    super.createdAt,
    super.lastSignIn,
    super.emailVerified,
    super.subscriptionTier,
    super.storageUsed,
    super.documentCount,
  });

  factory UserModel.fromSupabaseUser(User user, {Map<String, dynamic>? profile}) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: profile?['display_name'] as String? ?? user.userMetadata?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String? ?? user.userMetadata?['avatar_url'] as String?,
      phone: user.phone,
      createdAt: user.createdAt != null ? DateTime.tryParse(user.createdAt!) : null,
      lastSignIn: user.lastSignInAt != null ? DateTime.tryParse(user.lastSignInAt!) : null,
      emailVerified: user.emailConfirmedAt != null,
      subscriptionTier: profile?['subscription_tier'] as String? ?? 'free',
      storageUsed: profile?['storage_used'] as int? ?? 0,
      documentCount: profile?['document_count'] as int? ?? 0,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      lastSignIn: json['last_sign_in'] != null
          ? DateTime.tryParse(json['last_sign_in'] as String)
          : null,
      emailVerified: json['email_verified'] as bool? ?? false,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      storageUsed: json['storage_used'] as int? ?? 0,
      documentCount: json['document_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in': lastSignIn?.toIso8601String(),
      'email_verified': emailVerified,
      'subscription_tier': subscriptionTier,
      'storage_used': storageUsed,
      'document_count': documentCount,
    };
  }
}
