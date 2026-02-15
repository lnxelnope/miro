/// Cuisine preference options — shared between Onboarding and Profile Settings
class CuisineOptions {
  CuisineOptions._();

  static const List<Map<String, String>> options = [
    {'key': 'international', 'label': 'International / Mixed', 'flag': '🌍'},
    {'key': 'thai',          'label': 'Thai',                  'flag': '🇹🇭'},
    {'key': 'japanese',      'label': 'Japanese',              'flag': '🇯🇵'},
    {'key': 'korean',        'label': 'Korean',                'flag': '🇰🇷'},
    {'key': 'chinese',       'label': 'Chinese',               'flag': '🇨🇳'},
    {'key': 'indian',        'label': 'Indian',                'flag': '🇮🇳'},
    {'key': 'american',      'label': 'American',              'flag': '🇺🇸'},
    {'key': 'mexican',       'label': 'Mexican',               'flag': '🇲🇽'},
    {'key': 'italian',       'label': 'Italian',               'flag': '🇮🇹'},
    {'key': 'mediterranean', 'label': 'Mediterranean',         'flag': '🫒'},
    {'key': 'middle_eastern','label': 'Middle Eastern',        'flag': '🇸🇦'},
    {'key': 'vietnamese',    'label': 'Vietnamese',            'flag': '🇻🇳'},
    {'key': 'indonesian',    'label': 'Indonesian',            'flag': '🇮🇩'},
    {'key': 'filipino',      'label': 'Filipino',              'flag': '🇵🇭'},
    {'key': 'european',      'label': 'European',              'flag': '🇪🇺'},
  ];

  /// Get display label for a cuisine key
  static String getLabel(String key) {
    return options.firstWhere(
      (o) => o['key'] == key,
      orElse: () => options.first,
    )['label']!;
  }

  /// Get flag emoji for a cuisine key
  static String getFlag(String key) {
    return options.firstWhere(
      (o) => o['key'] == key,
      orElse: () => options.first,
    )['flag']!;
  }
}
