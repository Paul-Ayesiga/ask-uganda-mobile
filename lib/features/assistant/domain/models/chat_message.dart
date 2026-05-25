import 'package:flutter/foundation.dart';

import 'consent_proposal.dart';
import 'field_request.dart';
import 'verified_fact.dart';

enum ChatRole { citizen, assistant, system }

enum ChatContentKind {
  text,
  verifiedFact,
  consentProposal,
  handoff,
  action,
  fieldRequest,
}

String _roleName(ChatRole r) {
  switch (r) {
    case ChatRole.citizen:
      return 'citizen';
    case ChatRole.assistant:
      return 'assistant';
    case ChatRole.system:
      return 'system';
  }
}

ChatRole _roleFrom(String s) {
  switch (s) {
    case 'citizen':
      return ChatRole.citizen;
    case 'system':
      return ChatRole.system;
    default:
      return ChatRole.assistant;
  }
}

String _kindName(ChatContentKind k) {
  switch (k) {
    case ChatContentKind.verifiedFact:
      return 'verified_fact';
    case ChatContentKind.consentProposal:
      return 'consent_proposal';
    case ChatContentKind.handoff:
      return 'handoff';
    case ChatContentKind.action:
      return 'action';
    case ChatContentKind.fieldRequest:
      return 'field_request';
    case ChatContentKind.text:
      return 'text';
  }
}

ChatContentKind _kindFrom(String s) {
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

@immutable
class ChatAction {
  const ChatAction({required this.label, required this.actionId, this.icon});

  final String label;
  final String actionId;
  final String? icon;

  Map<String, dynamic> toJson() => {
        'label': label,
        'action_id': actionId,
        if (icon != null) 'icon': icon,
      };

  factory ChatAction.fromJson(Map<String, dynamic> json) {
    return ChatAction(
      label: json['label'] as String? ?? '',
      actionId: json['action_id'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }
}

@immutable
class HandoffSummary {
  const HandoffSummary({
    required this.agency,
    required this.officeName,
    required this.contact,
    required this.contextSummary,
  });

  final String agency;
  final String officeName;
  final String contact;
  final String contextSummary;

  Map<String, dynamic> toJson() => {
        'agency': agency,
        'office_name': officeName,
        'contact': contact,
        'context_summary': contextSummary,
      };

  factory HandoffSummary.fromJson(Map<String, dynamic> json) {
    return HandoffSummary(
      agency: json['agency'] as String? ?? '',
      officeName: json['office_name'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      contextSummary: json['context_summary'] as String? ?? '',
    );
  }
}

@immutable
class ChatMessage {
  const ChatMessage({
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
    this.isStreaming = false,
    this.consentDecision,
    this.fieldSubmission,
  });

  final String id;
  final ChatRole role;
  final ChatContentKind kind;
  final DateTime createdAt;
  final String? text;
  final VerifiedFact? verifiedFact;
  final ConsentProposal? consentProposal;
  final HandoffSummary? handoff;
  final FieldRequest? fieldRequest;
  final List<ChatAction> actions;
  final bool isStreaming;

  /// For a [ChatContentKind.consentProposal] message: null until the
  /// citizen decides, then true (Allow) or false (Decline). Drives the
  /// card's button/status rendering directly, so the UI does not depend
  /// on any global "active proposal" flag.
  final bool? consentDecision;

  /// For a [ChatContentKind.fieldRequest] message: null until the
  /// citizen submits a value, then the map they sent (typically
  /// `{fieldRequest.id: value}`). Lets the card flip from input to a
  /// read-only "submitted" state and survives reload from disk.
  final Map<String, String>? fieldSubmission;

  ChatMessage copyWith({
    String? text,
    bool? isStreaming,
    List<ChatAction>? actions,
    Object? consentDecision = _sentinel,
    Object? fieldSubmission = _sentinel,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      kind: kind,
      createdAt: createdAt,
      text: text ?? this.text,
      verifiedFact: verifiedFact,
      consentProposal: consentProposal,
      handoff: handoff,
      fieldRequest: fieldRequest,
      actions: actions ?? this.actions,
      isStreaming: isStreaming ?? this.isStreaming,
      consentDecision: identical(consentDecision, _sentinel)
          ? this.consentDecision
          : consentDecision as bool?,
      fieldSubmission: identical(fieldSubmission, _sentinel)
          ? this.fieldSubmission
          : fieldSubmission as Map<String, String>?,
    );
  }

  /// JSON-serialisable snapshot used by the local conversation store.
  /// `isStreaming` is intentionally not persisted — a message reloaded
  /// from disk is always finalised.
  Map<String, dynamic> toJson() => {
        'id': id,
        'role': _roleName(role),
        'kind': _kindName(kind),
        'created_at': createdAt.toIso8601String(),
        if (text != null) 'text': text,
        if (verifiedFact != null) 'verified_fact': verifiedFact!.toJson(),
        if (consentProposal != null)
          'consent_proposal': consentProposal!.toJson(),
        if (handoff != null) 'handoff': handoff!.toJson(),
        if (fieldRequest != null) 'field_request': fieldRequest!.toJson(),
        if (actions.isNotEmpty)
          'actions': actions.map((a) => a.toJson()).toList(),
        if (consentDecision != null) 'consent_decision': consentDecision,
        if (fieldSubmission != null) 'field_submission': fieldSubmission,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: _roleFrom(json['role'] as String? ?? 'assistant'),
      kind: _kindFrom(json['kind'] as String? ?? 'text'),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
              DateTime.now(),
      text: json['text'] as String?,
      verifiedFact: json['verified_fact'] == null
          ? null
          : VerifiedFact.fromJson(
              json['verified_fact'] as Map<String, dynamic>,
            ),
      consentProposal: json['consent_proposal'] == null
          ? null
          : ConsentProposal.fromJson(
              json['consent_proposal'] as Map<String, dynamic>,
            ),
      handoff: json['handoff'] == null
          ? null
          : HandoffSummary.fromJson(json['handoff'] as Map<String, dynamic>),
      fieldRequest: json['field_request'] == null
          ? null
          : FieldRequest.fromJson(
              json['field_request'] as Map<String, dynamic>,
            ),
      actions: ((json['actions'] as List?) ?? const [])
          .map((a) => ChatAction.fromJson(a as Map<String, dynamic>))
          .toList(growable: false),
      consentDecision: json['consent_decision'] as bool?,
      fieldSubmission: json['field_submission'] == null
          ? null
          : (json['field_submission'] as Map).cast<String, String>(),
    );
  }
}

const _sentinel = Object();
