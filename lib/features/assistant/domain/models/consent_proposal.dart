import 'package:flutter/foundation.dart';

enum ConsentScopeKind { identity, businessStatus, taxStatus, landRecord, qualification, healthEntitlement }

@immutable
class ConsentScope {
  const ConsentScope({
    required this.kind,
    required this.label,
    required this.purpose,
  });

  final ConsentScopeKind kind;
  final String label;
  final String purpose;
}

@immutable
class ConsentProposal {
  const ConsentProposal({
    required this.id,
    required this.authority,
    required this.purpose,
    required this.scopes,
    required this.validForMinutes,
  });

  final String id;
  final String authority;
  final String purpose;
  final List<ConsentScope> scopes;
  final int validForMinutes;
}
