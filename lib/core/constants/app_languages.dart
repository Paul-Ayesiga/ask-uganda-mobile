import 'package:flutter/foundation.dart';

@immutable
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.greeting,
    required this.region,
    this.voiceReady = true,
  });

  final String code;
  final String englishName;
  final String nativeName;
  final String greeting;
  final String region;
  final bool voiceReady;
}

abstract final class AppLanguages {
  static const english = AppLanguage(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    greeting: 'Welcome to Ask Uganda',
    region: 'National',
  );

  static const luganda = AppLanguage(
    code: 'lg',
    englishName: 'Luganda',
    nativeName: 'Luganda',
    greeting: 'Tukwaniriza ku Ask Uganda',
    region: 'Central',
  );

  static const runyankole = AppLanguage(
    code: 'nyn',
    englishName: 'Runyankole-Rukiga',
    nativeName: 'Runyankore-Rukiga',
    greeting: 'Tukutangiriire aha Ask Uganda',
    region: 'Western',
  );

  static const acholi = AppLanguage(
    code: 'ach',
    englishName: 'Acholi',
    nativeName: 'Leb Acoli',
    greeting: 'Wajolo wu i Ask Uganda',
    region: 'Northern',
  );

  static const ateso = AppLanguage(
    code: 'teo',
    englishName: 'Ateso',
    nativeName: 'Ateso',
    greeting: 'Eyalama noi Ask Uganda',
    region: 'Eastern',
    voiceReady: false,
  );

  static const lugbara = AppLanguage(
    code: 'lgg',
    englishName: 'Lugbara',
    nativeName: 'Lugbarati',
    greeting: 'Ami ovu Ask Uganda',
    region: 'West Nile',
    voiceReady: false,
  );

  static const swahili = AppLanguage(
    code: 'sw',
    englishName: 'Swahili',
    nativeName: 'Kiswahili',
    greeting: 'Karibu Ask Uganda',
    region: 'Cross-border',
  );

  static const all = <AppLanguage>[
    english,
    luganda,
    runyankole,
    acholi,
    ateso,
    lugbara,
    swahili,
  ];
}
