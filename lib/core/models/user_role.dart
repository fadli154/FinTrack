enum UserRole {
  admin,
  user;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  String toJson() => name;

  bool get isAdmin => this == UserRole.admin;
  bool get isUser => this == UserRole.user;
}
