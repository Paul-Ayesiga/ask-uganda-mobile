import 'package:flutter/foundation.dart';

enum ConsentScopeKind {
  identity,
  businessStatus,
  taxStatus,
  landRecord,
  qualification,
  healthEntitlement,
}

String _scopeKindName(ConsentScopeKind k) {
  switch (k) {
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

ConsentScopeKind _scopeKindFrom(String s) {
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

  Map<String, dynamic> toJson() => {
        'kind': _scopeKindName(kind),
        'label': label,
        'purpose': purpose,
      };

  factory ConsentScope.fromJson(Map<String, dynamic> json) {
    return ConsentScope(
      kind: _scopeKindFrom(json['kind'] as String? ?? 'identity'),
      label: json['label'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
    );
  }
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'authority': authority,
        'purpose': purpose,
        'scopes': scopes.map((s) => s.toJson()).toList(),
        'valid_for_minutes': validForMinutes,
      };

  factory ConsentProposal.fromJson(Map<String, dynamic> json) {
    return ConsentProposal(
      id: json['id'] as String? ?? '',
      authority: json['authority'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      scopes: ((json['scopes'] as List?) ?? const [])
          .map((s) => ConsentScope.fromJson(s as Map<String, dynamic>))
          .toList(growable: false),
      validForMinutes: json['valid_for_minutes'] as int? ?? 15,
    );
  }
}
