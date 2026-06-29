import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/repositories/user_repository.dart';

/// Called after every sign-in or registration.
/// Migrates legacy user documents and updates last_login timestamp.
class AuthService {
  AuthService._();

  static Future<AppUser> postLogin(User firebaseUser) async {
    return UserRepository.migrateUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email ?? '',
      email: firebaseUser.email ?? '',
    );
  }
}
