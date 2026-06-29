enum UserStatus {
  active,
  disabled;

  static UserStatus fromString(String? value) {
    switch (value) {
      case 'disabled':
        return UserStatus.disabled;
      case 'active':
      default:
        return UserStatus.active;
    }
  }

  String toJson() => name;

  bool get isActive => this == UserStatus.active;
  bool get isDisabled => this == UserStatus.disabled;
}
