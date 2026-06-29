import 'package:fintrack/controllers/user_controller.dart';
import 'package:fintrack/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Middleware for admin-only routes.
/// Redirects to /unauthorized if the current user is not an admin.
class RoleGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final userController = Get.find<UserController>();
    final user = userController.currentUser.value;

    if (!PermissionService.canAccessAdminPanel(user)) {
      return const RouteSettings(name: '/unauthorized');
    }
    return null; // Allow navigation
  }
}
