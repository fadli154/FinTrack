import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/models/user_role.dart';

/// Stateless permission checks. All role logic lives here — never duplicated elsewhere.
class PermissionService {
  PermissionService._(); // prevent instantiation

  static bool isAdmin(AppUser? user) =>
      user != null && user.role == UserRole.admin && user.isActive;

  static bool canManageUsers(AppUser? user) => isAdmin(user);

  static bool canViewAllTransactions(AppUser? user) => isAdmin(user);

  static bool canManageGlobalCategories(AppUser? user) => isAdmin(user);

  static bool canAccessAdminPanel(AppUser? user) => isAdmin(user);

  static bool canChangeRole(AppUser? actor, AppUser? target) {
    if (!isAdmin(actor)) return false;
    if (target == null) return false;
    // Admins cannot demote themselves
    if (actor!.uid == target.uid) return false;
    return true;
  }

  static bool canDeleteUser(AppUser? actor, AppUser? target) {
    if (!isAdmin(actor)) return false;
    if (target == null) return false;
    // Cannot delete yourself
    if (actor!.uid == target.uid) return false;
    return true;
  }
}
