/// App mode for admin users — determines which shell they see.
/// Persisted in Firestore as `app_mode` field on the user document.
enum AppMode {
  admin,
  user;

  static AppMode fromString(String? value) =>
      value == 'user' ? AppMode.user : AppMode.admin;

  String toJson() => name;

  bool get isAdmin => this == AppMode.admin;
  bool get isUser => this == AppMode.user;
}
