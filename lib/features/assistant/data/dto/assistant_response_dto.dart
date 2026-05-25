// Wire DTOs the SSE stream parser hands the UI layer. Mirrors the
// `message` event payload documented in
// services/orchestration/app/agent/runner.py.

import '../../domain/models/chat_message.dart';
import '../../domain/models/consent_proposal.dart';
import '../../domain/models/field_request.dart';
import '../../domain/models/verified_fact.dart';

class AssistantMessageDto {
  AssistantMessageDto({
    required this.id,
    required this.role,
    required this.kind,
    required this.createdAt,
    this.text,
    this.verifiedFact,
    this.consentProposal,
    this.handoff,
    this.fieldRequest,
    this.actions = const [],
  });

  final String id;
  final String role;
  final String kind;
  final DateTime createdAt;
  final String? text;
  final VerifiedFactDto? verifiedFact;
  final ConsentProposalDto? consentProposal;
  final HandoffDto? handoff;

  /// The backend's FieldRequest wire shape matches the domain model
  /// one-to-one (no client-only fields), so we reuse the domain class
  /// here rather than maintain a parallel DTO.
  final FieldRequest? fieldRequest;
  final List<ChatActionDto> actions;

  factory AssistantMessageDto.fromJson(Map<String, dynamic> json) {
    return AssistantMessageDto(
      id: json['id'] as String,
      role: json['role'] as String? ?? 'assistant',
      kind: json['kind'] as String? ?? 'text',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      text: json['text'] as String?,
      verifiedFact: json['verified_fact'] == null
          ? null
          : VerifiedFactDto.fromJson(
              json['verified_fact'] as Map<String, dynamic>,
            ),
      consentProposal: json['consent_proposal'] == null
          ? null
          : ConsentProposalDto.fromJson(
              json['consent_proposal'] as Map<String, dynamic>,
            ),
      handoff: json['handoff'] == null
          ? null
          : HandoffDto.fromJson(json['handoff'] as Map<String, dynamic>),
      fieldRequest: json['field_request'] == null
          ? null
          : FieldRequest.fromJson(
              json['field_request'] as Map<String, dynamic>,
            ),
      actions: ((json['actions'] as List?) ?? const [])
          .map((a) => ChatActionDto.fromJson(a as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  ChatMessage toDomain() {
    return ChatMessage(
      id: id,
      role: _roleFromString(role),
      kind: _kindFromString(kind),
      createdAt: createdAt,
      text: text,
      verifiedFact: verifiedFact?.toDomain(),
      consentProposal: consentProposal?.toDomain(),
      handoff: handoff?.toDomain(),
      fieldRequest: fieldRequest,
      actions: actions.map((a) => a.toDomain()).toList(growable: false),
    );
  }
}

ChatRole _roleFromString(String s) {
  switch (s) {
    case 'citizen':
      return ChatRole.citizen;
    case 'system':
      return ChatRole.system;
    default:
      return ChatRole.assistant;
  }
}

ChatContentKind _kindFromString(String s) {
  switch (s) {
    case 'verified_fact':
      return ChatContentKind.verifiedFact;
    case 'consent_proposal':
      return ChatContentKind.consentProposal;
    case 'handoff':
      return ChatContentKind.handoff;
    case 'action':
      return ChatContentKind.action;
    case 'field_request':
      return ChatContentKind.fieldRequest;
    default:
      return ChatContentKind.text;
  }
}

class VerifiedFactDto {
  VerifiedFactDto({
    required this.title,
    required this.summary,
    required this.fields,
    required this.authoritativeSource,
    required this.issuedAt,
    required this.requestId,
    this.consentReference,
  });

  final String title;
  final String summary;
  final List<VerifiedFieldDto> fields;
  final String authoritativeSource;
  final DateTime issuedAt;
  final String requestId;
  final String? consentReference;

  factory VerifiedFactDto.fromJson(Map<String, dynamic> json) {
    return VerifiedFactDto(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      fields: ((json['fields'] as List?) ?? const [])
          .map((f) => VerifiedFieldDto.fromJson(f as Map<String, dynamic>))
          .toList(growable: false),
      authoritativeSource: json['authoritative_source'] as String? ?? '',
      issuedAt: DateTime.tryParse(json['issued_at'] as String? ?? '') ??
          DateTime.now(),
      requestId: json['request_id'] as String? ?? '',
      consentReference: json['consent_reference'] as String?,
    );
  }

  VerifiedFact toDomain() {
    return VerifiedFact(
      title: title,
      summary: summary,
      fields: fields.map((f) => f.toDomain()).toList(growable: false),
      authoritativeSource: authoritativeSource,
      issuedAt: issuedAt,
      requestId: requestId,
      consentReference: consentReference,
    );
  }
}

class VerifiedFieldDto {
  VerifiedFieldDto({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  factory VerifiedFieldDto.fromJson(Map<String, dynamic> json) {
    return VerifiedFieldDto(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      note: json['note'] as String?,
    );
  }

  VerifiedField toDomain() => VerifiedField(label: label, value: value, note: note);
}

class ConsentProposalDto {
  ConsentProposalDto({
    required this.id,
    required this.authority,
    required this.purpose,
    required this.scopes,
    required this.validForMinutes,
  });

  final String id;
  final String authority;
  final String purpose;
  final List<ConsentScopeDto> scopes;
  final int validForMinutes;

  factory ConsentProposalDto.fromJson(Map<String, dynamic> json) {
    return ConsentProposalDto(
      id: json['id'] as String? ?? '',
      authority: json['authority'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      scopes: ((json['scopes'] as List?) ?? const [])
          .map((s) => ConsentScopeDto.fromJson(s as Map<String, dynamic>))
          .toList(growable: false),
      validForMinutes: json['valid_for_minutes'] as int? ?? 15,
    );
  }

  ConsentProposal toDomain() {
    return ConsentProposal(
      id: id,
      authority: authority,
      purpose: purpose,
      scopes: scopes.map((s) => s.toDomain()).toList(growable: false),
      validForMinutes: validForMinutes,
    );
  }
}

class ConsentScopeDto {
  ConsentScopeDto({
    required this.kind,
    required this.label,
    required this.purpose,
  });

  final String kind;
  final String label;
  final String purpose;

  factory ConsentScopeDto.fromJson(Map<String, dynamic> json) {
    return ConsentScopeDto(
      kind: json['kind'] as String? ?? 'identity',
      label: json['label'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
    );
  }

  ConsentScope toDomain() {
    return ConsentScope(
      kind: _scopeKindFromString(kind),
      label: label,
      purpose: purpose,
    );
  }
}

ConsentScopeKind _scopeKindFromString(String s) {
  switch (s) {
    case 'business_status':
      return ConsentScopeKind.businessStatus;
    case 'tax_status':
      return ConsentScopeKind.taxStatus;
    case 'land_record':
      return ConsentScopeKind.landRecord;
    case 'qualification':
      return ConsentScopeKind.qualification;
    case 'health_entitlement':
      return ConsentScopeKind.healthEntitlement;
    default:
      return ConsentScopeKind.identity;
  }
}

class HandoffDto {
  HandoffDto({
    required this.agency,
    required this.officeName,
    required this.contact,
    required this.contextSummary,
  });

  final String agency;
  final String officeName;
  final String contact;
  final String contextSummary;

  factory HandoffDto.fromJson(Map<String, dynamic> json) {
    return HandoffDto(
      agency: json['agency'] as String? ?? '',
      officeName: json['office_name'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      contextSummary: json['context_summary'] as String? ?? '',
    );
  }

  HandoffSummary toDomain() {
    return HandoffSummary(
      agency: agency,
      officeName: officeName,
      contact: contact,
      contextSummary: contextSummary,
    );
  }
}

class ChatActionDto {
  ChatActionDto({required this.label, required this.actionId, this.icon});

  final String label;
  final String actionId;
  final String? icon;

  factory ChatActionDto.fromJson(Map<String, dynamic> json) {
    return ChatActionDto(
      label: json['label'] as String? ?? '',
      actionId: json['action_id'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }

  ChatAction toDomain() => ChatAction(label: label, actionId: actionId);
}

class ConsentReceiptDto {
  ConsentReceiptDto({
    required this.consentId,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String consentId;
  final DateTime issuedAt;
  final DateTime expiresAt;

  factory ConsentReceiptDto.fromJson(Map<String, dynamic> json) {
    return ConsentReceiptDto(
      consentId: json['consent_id'] as String,
      issuedAt: DateTime.tryParse(json['issued_at'] as String? ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ??
          DateTime.now().add(const Duration(minutes: 15)),
    );
  }
}
