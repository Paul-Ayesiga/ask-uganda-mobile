import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';

class ApiClients {
  ApiClients({required this.orchestration, required this.guvaGateway});

  final Dio orchestration;
  final Dio guvaGateway;

  void close() {
    orchestration.close(force: true);
    guvaGateway.close(force: true);
  }
}

Dio _build(String baseUrl) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: AppConfig.httpTimeout,
      responseType: ResponseType.json,
      headers: {'Content-Type': 'application/json'},
    ),
  );
}

final apiClientsProvider = Provider<ApiClients>((ref) {
  final clients = ApiClients(
    orchestration: _build(AppConfig.orchestrationBaseUrl),
    guvaGateway: _build(AppConfig.guvaGatewayBaseUrl),
  );
  ref.onDispose(clients.close);
  return clients;
});
