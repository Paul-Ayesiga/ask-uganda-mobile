import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_languages.dart';

@immutable
class UserPreferences {
  const UserPreferences({
    required this.language,
    required this.voiceFirst,
    required this.highContrast,
    required this.textScale,
    required this.onboardingComplete,
  });

  factory UserPreferences.initial() {
    return const UserPreferences(
      language: AppLanguages.english,
      voiceFirst: false,
      highContrast: false,
      textScale: 1.0,
      onboardingComplete: false,
    );
  }

  final AppLanguage language;
  final bool voiceFirst;
  final bool highContrast;
  final double textScale;
  final bool onboardingComplete;

  UserPreferences copyWith({
    AppLanguage? language,
    bool? voiceFirst,
    bool? highContrast,
    double? textScale,
    bool? onboardingComplete,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      voiceFirst: voiceFirst ?? this.voiceFirst,
      highContrast: highContrast ?? this.highContrast,
      textScale: textScale ?? this.textScale,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

class PreferencesController extends StateNotifier<UserPreferences> {
  PreferencesController() : super(UserPreferences.initial());

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void setVoiceFirst(bool value) {
    state = state.copyWith(voiceFirst: value);
  }

  void setHighContrast(bool value) {
    state = state.copyWith(highContrast: value);
  }

  void setTextScale(double value) {
    state = state.copyWith(textScale: value);
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
  }
}

final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, UserPreferences>(
      (ref) => PreferencesController(),
    );
