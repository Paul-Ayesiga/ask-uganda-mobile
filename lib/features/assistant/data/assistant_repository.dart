import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../domain/models/consent_proposal.dart';
import 'api_client.dart';
import 'dto/assistant_response_dto.dart';
import 'sse.dart';

/// Discriminated-union of the events the orchestration SSE stream emits.
/// Maps to the `event:` lines in services/orchestration/app/domain/orchestrator.py
/// `handle_stream` docstring.
sealed class AssistantStreamEvent {
  const AssistantStreamEvent();
}

class StreamStart extends AssistantStreamEvent {
  const StreamStart({
    required this.threadId,
    required this.language,
    required this.intent,
  });
  final String threadId;
  final String language;
  final String intent;
}

/// A complete structured assistant message produced before or after the
/// streamed text reply — consent proposals and verified facts arrive
/// this way.
class StreamMessage extends AssistantStreamEvent {
  const StreamMessage(this.dto);
  final AssistantMessageDto dto;
}

class StreamMessageStart extends AssistantStreamEvent {
  const StreamMessageStart({required this.messageId});
  final String messageId;
}

class StreamDelta extends AssistantStreamEvent {
  const StreamDelta({required this.messageId, required this.text});
  final String messageId;
  final String text;
}

class StreamMessageEnd extends AssistantStreamEvent {
  const StreamMessageEnd({required this.messageId, required this.fullText});
  final String messageId;
  final String fullText;
}

class StreamDone extends AssistantStreamEvent {
  const StreamDone({required this.groundedSources});
  final List<String> groundedSources;
}

class StreamError extends AssistantStreamEvent {
  const StreamError(this.detail);
  final String detail;
}

/// Anything callers need to know about a failed backend call. Keeps Dio's
/// transport-shaped exceptions out of the UI layer.
class AssistantApiException implements Exception {
  AssistantApiException(this.message, {this.status, this.cause});

  final String message;
  final int? status;
  final Object? cause;

  @override
  String toString() => 'AssistantApiException($status): $message';
}

class AssistantRepository {
  AssistantRepository({required this.orchestration, required this.guvaGateway});

  final Dio orchestration;
  final Dio guvaGateway;

  /// POST /v1/messages on the orchestration service. `consentToken` is
  /// supplied on the *retry* after the citizen has approved a consent
  /// proposal; the first call always omits it.
  Future<AssistantResponseDto> sendMessage({
    required String text,
    required String language,
    required String citizenId,
    String? threadId,
    String? consentToken,
  }) async {
    try {
      final response = await orchestration.post<Map<String, dynamic>>(
        '/v1/messages',
        data: {
          'text': text,
          'language': language,
          'channel': AppConfig.channel,
          'thread_id': ?threadId,
          'consent_token': ?consentToken,
        },
        options: Options(headers: {'X-Citizen-Id': citizenId}),
      );
      return AssistantResponseDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw _translate(e, 'send message');
    }
  }

  /// POST /v1/consent/record on the GUVA gateway. Returns the consent_id
  /// the caller then re-sends as `consent_token` on the next message.
  Future<ConsentReceiptDto> recordConsent({
    required ConsentProposal proposal,
    required String citizenId,
  }) async {
    try {
      final response = await guvaGateway.post<Map<String, dynamic>>(
        '/v1/consent/record',
        data: {
          'citizen_pseudonym': citizenId,
          'scopes': proposal.scopes.map((s) => _scopeWire(s.kind)).toList(),
          'purpose': proposal.purpose,
          'authority': proposal.authority,
          'valid_for_minutes': proposal.validForMinutes,
        },
      );
      return ConsentReceiptDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw _translate(e, 'record consent');
    }
  }

  /// Streaming variant of [sendMessage]. Yields parsed events as the
  /// orchestration produces them: thread/intent metadata, fully-formed
  /// structured messages (consent_proposal, verified_fact), then deltas
  /// of the streamed text reply, then done.
  Stream<AssistantStreamEvent> streamMessage({
    required String text,
    required String language,
    required String citizenId,
    String? threadId,
    String? consentToken,
  }) async* {
    final raw = openSseStream(
      dio: orchestration,
      path: '/v1/messages/stream',
      headers: {'X-Citizen-Id': citizenId},
      body: {
        'text': text,
        'language': language,
        'channel': AppConfig.channel,
        'thread_id': ?threadId,
        'consent_token': ?consentToken,
      },
    );

    await for (final e in raw) {
      switch (e.name) {
        case 'start':
          yield StreamStart(
            threadId: e.data['thread_id'] as String,
            language: e.data['language'] as String? ?? 'en',
            intent: e.data['intent'] as String? ?? 'procedural',
          );
          break;
        case 'message':
          yield StreamMessage(AssistantMessageDto.fromJson(e.data));
          break;
        case 'message_start':
          yield StreamMessageStart(messageId: e.data['id'] as String);
          break;
        case 'delta':
          yield StreamDelta(
            messageId: e.data['id'] as String,
            text: e.data['text'] as String? ?? '',
          );
          break;
        case 'message_end':
          yield StreamMessageEnd(
            messageId: e.data['id'] as String,
            fullText: e.data['text'] as String? ?? '',
          );
          break;
        case 'done':
          yield StreamDone(
            groundedSources: ((e.data['grounded_sources'] as List?) ?? const [])
                .map((s) => s as String)
                .toList(growable: false),
          );
          break;
        case 'error':
          yield StreamError(e.data['detail'] as String? ?? 'stream error');
          break;
      }
    }
  }

  AssistantApiException _translate(DioException e, String action) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String detail;
    if (body is Map<String, dynamic>) {
      detail = body['detail'] as String? ??
          body['title'] as String? ??
          body.toString();
    } else if (body is String) {
      detail = body;
    } else {
      detail = e.message ?? 'unknown transport error';
    }
    return AssistantApiException(
      'Failed to $action: $detail',
      status: status,
      cause: e,
    );
  }
}

String _scopeWire(ConsentScopeKind kind) {
  switch (kind) {
    case ConsentScopeKind.identity:
      return 'identity';
    case ConsentScopeKind.businessStatus:
      return 'business_status';
    case ConsentScopeKind.taxStatus:
      return 'tax_status';
    case ConsentScopeKind.landRecord:
      return 'land_record';
    case ConsentScopeKind.qualification:
      return 'qualification';
    case ConsentScopeKind.healthEntitlement:
      return 'health_entitlement';
  }
}

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final clients = ref.watch(apiClientsProvider);
  return AssistantRepository(
    orchestration: clients.orchestration,
    guvaGateway: clients.guvaGateway,
  );
});
