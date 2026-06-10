import 'package:intl/intl.dart';

/// Extension methods for [DateTime] formatting.
extension DateTimeExtension on DateTime {
  /// Formats the [DateTime] into a string using the given [pattern].
  /// Default pattern is 'dd MMMM yyyy' (e.g., 06 June 2026).
  String toFormattedString([String pattern = 'dd MMMM yyyy']) {
    return DateFormat(pattern).format(this);
  }

  /// Returns date formatted as 'dd MMMM yyyy' (e.g., 06 June 2026).
  String get toFormattedDate => toFormattedString('dd MMMM yyyy');

  /// Returns time formatted as 'HH:mm' (e.g., 14:30).
  String get toFormattedTime => toFormattedString('HH:mm');

  /// Returns date & time formatted as 'dd MMMM yyyy, HH:mm' (e.g., 06 June 2026, 14:30).
  String get toFormattedDateTime => toFormattedString('dd MMMM yyyy, HH:mm');
}

/// Extension methods for [String] to parse and format dates.
extension DateTimeStringExtension on String {
  /// Parses the string into a [DateTime]. Returns null if invalid.
  DateTime? get toDateTime => DateTime.tryParse(this);

  /// Parses the string into [DateTime] and formats it using the given [pattern].
  /// Returns the original string if parsing fails.
  String toFormattedDate([String pattern = 'dd MMMM yyyy']) {
    final parsed = toDateTime;
    if (parsed == null) return this;
    return parsed.toFormattedString(pattern);
  }

  /// Parses the string into [DateTime] and returns date formatted as 'dd MMMM yyyy'.
  /// Returns the original string if parsing fails.
  String get toFormattedDateDefault => toFormattedDate('dd MMMM yyyy');

  /// Parses the string into [DateTime] and returns time formatted as 'HH:mm'.
  /// Returns the original string if parsing fails.
  String get toFormattedTimeDefault => toFormattedDate('HH:mm');

  /// Parses the string into [DateTime] and returns date & time formatted as 'dd MMMM yyyy, HH:mm'.
  /// Returns the original string if parsing fails.
  String get toFormattedDateTimeDefault =>
      toFormattedDate('dd MMMM yyyy, HH:mm');
}
