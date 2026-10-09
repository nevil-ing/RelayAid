abstract final class ReportValidation {
  static String? title(String? value) {
    final text = value?.trim() ?? '';
    return text.length < 3 || text.length > 120
        ? 'Add a title of 3–120 characters.'
        : null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    return text.length < 3 || text.length > 5000
        ? 'Describe what happened in 3–5000 characters.'
        : null;
  }

  static String? peopleAffected(String? value) {
    final count = int.tryParse(value?.trim() ?? '');
    return count == null || count < 0 || count > 1000000
        ? 'Enter a whole number from 0 to 1000000.'
        : null;
  }

  static String? coordinate(
    String? value, {
    required bool latitude,
    required String other,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty && other.trim().isEmpty) return null;
    if (text.isEmpty || other.trim().isEmpty) return 'Enter both coordinates.';
    final number = double.tryParse(text);
    final limit = latitude ? 90 : 180;
    return number == null || !number.isFinite || number.abs() > limit
        ? 'Enter a value from -$limit to $limit.'
        : null;
  }
}
