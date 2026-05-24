/// Compile-time configuration injected via --dart-define.
///
/// Defaults are tuned for the iOS simulator talking to a backend running
/// in Docker Desktop on the same Mac. Adjust per platform:
///
///   iOS simulator    → http://127.0.0.1:7100   (shares host network)
///   Android emulator → http://10.0.2.2:7100    (host alias)
///   Physical device  → `http://<your-mac-lan-ip>:7100`
///
/// To override at build time:
///   flutter run --dart-define=ORCHESTRATION_BASE_URL=http://192.168.1.42:7100 \
///               --dart-define=GUVA_GATEWAY_BASE_URL=http://192.168.1.42:7120
abstract final class AppConfig {
  static const orchestrationBaseUrl = String.fromEnvironment(
    'ORCHESTRATION_BASE_URL',
    defaultValue: 'http://127.0.0.1:7100',
  );

  static const guvaGatewayBaseUrl = String.fromEnvironment(
    'GUVA_GATEWAY_BASE_URL',
    defaultValue: 'http://127.0.0.1:7120',
  );

  /// Channel identifier sent on every request. Maps to the `channel`
  /// field in the orchestration CitizenMessageRequest.
  static const channel = 'mobile';

  /// Hard cap for any single backend call. The orchestrator on the
  /// server has its own (shorter) upstream timeouts; this is the
  /// client-side ceiling.
  static const Duration httpTimeout = Duration(seconds: 90);
}
