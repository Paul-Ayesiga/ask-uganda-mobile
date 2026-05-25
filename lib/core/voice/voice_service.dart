import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// What the UI needs to know about voice availability.
class VoiceAvailability {
  const VoiceAvailability({
    required this.sttReady,
    required this.languageSupported,
    required this.notes,
  });

  /// Speech-to-text initialised and permissions granted.
  final bool sttReady;

  /// The currently selected language has a device locale we can use for
  /// recognition. Luganda is typically false on iOS today — STT
  /// gracefully refuses and the UI tells the citizen.
  final bool languageSupported;

  /// Human-readable detail to show in the UI (e.g. "Voice support is
  /// coming for Luganda — please type for now").
  final String? notes;
}

/// Maps an Ask Uganda language code to a BCP-47 locale that
/// speech_to_text and flutter_tts both understand. Languages without
/// device-level support map to null — callers degrade to text-only.
String? bcp47For(String code) {
  switch (code) {
    case 'en':
      return 'en-US';
    case 'sw':
      return 'sw-KE';
    // The following don't typically have iOS Speech locales today.
    // Returning null causes the UI to display a friendly fallback.
    case 'lg':   // Luganda
    case 'nyn':  // Runyankole-Rukiga
    case 'ach':  // Acholi
    case 'teo':  // Ateso
    case 'lgg':  // Lugbara
      return null;
    default:
      return null;
  }
}

/// Thin wrapper around speech_to_text + flutter_tts. Owns the lifecycle
/// of both engines; UI code interacts with this service via Riverpod.
class VoiceService {
  VoiceService();

  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttInitialised = false;
  Set<String> _availableSttLocales = const {};
  StreamSubscription<dynamic>? _resultsSubscription;

  Future<VoiceAvailability> initialiseForLanguage(String languageCode) async {
    if (!_sttInitialised) {
      _sttInitialised = await _stt.initialize(
        onError: (e) {/* surface via results stream instead */},
        onStatus: (_) {},
      );
      if (_sttInitialised) {
        final locales = await _stt.locales();
        _availableSttLocales = {for (final l in locales) l.localeId};
      }
    }

    final locale = bcp47For(languageCode);
    final supported =
        locale != null && _availableSttLocales.any(
          (id) => id == locale || id.toLowerCase().startsWith(
            locale.split('-').first.toLowerCase(),
          ),
        );

    String? notes;
    if (!_sttInitialised) {
      notes =
          'Microphone access is required for voice input. Enable it in '
          'Settings, then try again.';
    } else if (locale == null) {
      notes =
          'Voice support for this language is on the way. Please type '
          'your question for now.';
    } else if (!supported) {
      notes =
          'Your device does not have voice recognition installed for '
          'this language. Please type for now.';
    }

    return VoiceAvailability(
      sttReady: _sttInitialised,
      languageSupported: supported,
      notes: notes,
    );
  }

  /// Begin recognition. Emits partial + final transcripts. Closes when
  /// the citizen stops speaking, taps stop, or the timeout fires.
  Stream<VoiceTranscript> startListening({
    required String languageCode,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) {
    final controller = StreamController<VoiceTranscript>.broadcast();
    final locale = bcp47For(languageCode);
    if (!_sttInitialised || locale == null) {
      controller.add(
        const VoiceTranscript(
          text: '',
          isFinal: true,
          error: 'voice recognition not available for this language',
        ),
      );
      controller.close();
      return controller.stream;
    }

    _stt.listen(
      listenOptions: stt.SpeechListenOptions(
        localeId: locale,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (r) {
        controller.add(
          VoiceTranscript(
            text: r.recognizedWords,
            isFinal: r.finalResult,
          ),
        );
        if (r.finalResult) {
          controller.close();
        }
      },
    );
    return controller.stream;
  }

  Future<void> stopListening() async {
    if (!_sttInitialised) return;
    await _stt.stop();
    await _resultsSubscription?.cancel();
    _resultsSubscription = null;
  }

  /// Speak [text] using the device's TTS engine. No-op when the device
  /// has no voice for the requested language.
  Future<void> speak(String text, {required String languageCode}) async {
    final locale = bcp47For(languageCode);
    if (locale == null) return;
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.5);   // FlutterTts: 0.0..1.0 (iOS) – slow & clear.
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  void dispose() {
    _resultsSubscription?.cancel();
    _stt.cancel();
    _tts.stop();
  }
}

class VoiceTranscript {
  const VoiceTranscript({
    required this.text,
    required this.isFinal,
    this.error,
  });

  final String text;
  final bool isFinal;
  final String? error;
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(service.dispose);
  return service;
});
