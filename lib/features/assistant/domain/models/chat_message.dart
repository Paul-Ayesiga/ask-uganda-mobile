import 'package:flutter/foundation.dart';

import 'consent_proposal.dart';
import 'verified_fact.dart';

enum ChatRole { citizen, assistant, system }

enum ChatContentKind { text, verifiedFact, consentProposal, handoff, action }

@immutable
class ChatAction {
  const ChatAction({required this.label, required this.actionId, this.icon});

  final String label;
  final String actionId;
  final String? icon;
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
    this.actions = const [],
    this.isStreaming = false,
  });

  final String id;
  final ChatRole role;
  final ChatContentKind kind;
  final DateTime createdAt;
  final String? text;
  final VerifiedFact? verifiedFact;
  final ConsentProposal? consentProposal;
  final HandoffSummary? handoff;
  final List<ChatAction> actions;
  final bool isStreaming;

  ChatMessage copyWith({
    String? text,
    bool? isStreaming,
    List<ChatAction>? actions,
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
      actions: actions ?? this.actions,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
