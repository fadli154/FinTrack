import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/models/app_mode.dart';
import 'package:fintrack/core/models/user_role.dart';
import 'package:fintrack/core/models/user_status.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final UserStatus status;
  final AppMode appMode;
  final String language;
  final String currency;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.appMode = AppMode.user,
    this.language = 'en',
    this.currency = 'IDR',
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  bool get isAdmin => role.isAdmin;
  bool get isActive => status.isActive;
  bool get isDisabled => status.isDisabled;
  bool get isInAdminMode => isAdmin && appMode.isAdmin;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final role = UserRole.fromString(data['role'] as String?);

    // Smart default: if app_mode missing, admin users default to admin mode
    final AppMode appMode;
    if (data.containsKey('app_mode')) {
      appMode = AppMode.fromString(data['app_mode'] as String?);
    } else {
      appMode = role.isAdmin ? AppMode.admin : AppMode.user;
    }

    return AppUser(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: role,
      status: UserStatus.fromString(data['status'] as String?),
      appMode: appMode,
      language: data['language'] as String? ?? 'en',
      currency: data['currency'] as String? ?? 'IDR',
      photoUrl: data['photo_url'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
      lastLogin: (data['last_login'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role.toJson(),
        'status': status.toJson(),
        'app_mode': appMode.toJson(),
        'language': language,
        'currency': currency,
        'photo_url': photoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      };

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    UserStatus? status,
    AppMode? appMode,
    String? language,
    String? currency,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      appMode: appMode ?? this.appMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLogin: lastLogin,
    );
  }
}
