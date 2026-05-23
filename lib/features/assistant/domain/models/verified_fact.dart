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
}

@immutable
class VerifiedField {
  const VerifiedField({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;
}
