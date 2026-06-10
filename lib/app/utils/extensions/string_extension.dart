extension StringExtension on String {
  // ── Validation Helpers ──────────────────────────────────────────────────

  /// Verifies if the string is a valid email address.
  bool get isValidEmail {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(this);
  }

  /// Verifies if the string is a strong password (min 6 characters, at least one letter and one number).
  bool get isValidPassword {
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return passwordRegExp.hasMatch(this);
  }

  /// Verifies if the string is a valid numeric phone number (9-15 digits).
  bool get isValidPhoneNumber {
    final phoneRegExp = RegExp(r'^[0-9]{9,15}$');
    return phoneRegExp.hasMatch(this);
  }

  // ── Manipulation Helpers ────────────────────────────────────────────────

  /// Capitalizes the first character of the string.
  String get capitalizeFirst {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
