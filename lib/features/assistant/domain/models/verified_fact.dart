import 'package:flutter/foundation.dart';

@immutable
class VerifiedFact {
  const VerifiedFact({
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
  final List<VerifiedField> fields;
  final String authoritativeSource;
  final DateTime issuedAt;
  final String requestId;
  final String? consentReference;

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'fields': fields.map((f) => f.toJson()).toList(),
        'authoritative_source': authoritativeSource,
        'issued_at': issuedAt.toIso8601String(),
        'request_id': requestId,
        if (consentReference != null) 'consent_reference': consentReference,
      };

  factory VerifiedFact.fromJson(Map<String, dynamic> json) {
    return VerifiedFact(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      fields: ((json['fields'] as List?) ?? const [])
          .map((f) => VerifiedField.fromJson(f as Map<String, dynamic>))
          .toList(growable: false),
      authoritativeSource: json['authoritative_source'] as String? ?? '',
      issuedAt:
          DateTime.tryParse(json['issued_at'] as String? ?? '') ?? DateTime.now(),
      requestId: json['request_id'] as String? ?? '',
      consentReference: json['consent_reference'] as String?,
    );
  }
}

@immutable
class VerifiedField {
  const VerifiedField({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        if (note != null) 'note': note,
      };

  factory VerifiedField.fromJson(Map<String, dynamic> json) {
    return VerifiedField(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      note: json['note'] as String?,
    );
  }
}
