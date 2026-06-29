import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/models/user_role.dart';
import 'package:fintrack/core/models/user_status.dart';

/// Single source of truth for all reads/writes to `users/` collection.
class UserRepository {
  static final _db = FirebaseFirestore.instance;
  static final _col = _db.collection('users');

  // ─── READ ─────────────────────────────────────────────────────────────────

  static Future<AppUser?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  static Stream<AppUser?> watchUser(String uid) {
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  /// Admin only — returns all user documents ordered by creation date.
  static Stream<List<AppUser>> getAllUsers() {
    return _col
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppUser.fromFirestore).toList());
  }

  // ─── WRITE ────────────────────────────────────────────────────────────────

  static Future<void> updateUser(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    fields['updated_at'] = FieldValue.serverTimestamp();
    await _col.doc(uid).update(fields);
  }

  static Future<void> setRole(String uid, UserRole role) async {
    await updateUser(uid, {'role': role.toJson()});
  }

  static Future<void> setStatus(String uid, UserStatus status) async {
    await updateUser(uid, {'status': status.toJson()});
  }

  static Future<void> deleteUser(String uid) async {
    await _col.doc(uid).delete();
  }

  static Future<void> updateLastLogin(String uid) async {
    await _col.doc(uid).update({
      'last_login': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ─── MIGRATION ────────────────────────────────────────────────────────────

  /// Idempotent — only writes fields that are missing.
  /// Call on every login/register to ensure all users have the new fields.
  static Future<AppUser> migrateUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    final ref = _col.doc(uid);
    final doc = await ref.get();

    if (!doc.exists) {
      // Brand new user (shouldn't normally happen via this path)
      await ref.set({
        'name': name,
        'email': email,
        'role': UserRole.user.toJson(),
        'status': UserStatus.active.toJson(),
        'language': 'en',
        'currency': 'IDR',
        'photo_url': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
      });
    } else {
      final data = doc.data() as Map<String, dynamic>;
      final updates = <String, dynamic>{
        'last_login': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (!data.containsKey('role')) updates['role'] = UserRole.user.toJson();
      if (!data.containsKey('status')) {
        updates['status'] = UserStatus.active.toJson();
      }
      if (!data.containsKey('language')) updates['language'] = 'en';
      if (!data.containsKey('currency')) updates['currency'] = 'IDR';
      if (!data.containsKey('photo_url')) updates['photo_url'] = null;

      await ref.update(updates);
    }

    final updated = await ref.get();
    return AppUser.fromFirestore(updated);
  }

  // ─── GLOBAL CATEGORIES ────────────────────────────────────────────────────

  static final _cats = _db.collection('categories');

  static Stream<List<Map<String, dynamic>>> watchGlobalCategories() {
    return _cats.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList(),
        );
  }

  static Future<void> addGlobalCategory(String name, String icon) async {
    await _cats.add({
      'name': name,
      'icon': icon,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteGlobalCategory(String id) async {
    await _cats.doc(id).delete();
  }
}
