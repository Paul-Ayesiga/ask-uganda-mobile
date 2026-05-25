import 'package:flutter/foundation.dart';

/// How the channel should render the input for a [FieldRequest]. Maps to
/// the FieldKind enum on the backend; adding a new value here requires
/// the matching backend addition and a UI mapping in FieldRequestCard.
enum FieldKind {
  text,
  number,
  nationalId,
  tin,
  businessReg,
  parcelId,
  date,
  choice,
}

String fieldKindWire(FieldKind k) {
  switch (k) {
    case FieldKind.text:
      return 'text';
    case FieldKind.number:
      return 'number';
    case FieldKind.nationalId:
      return 'national_id';
    case FieldKind.tin:
      return 'tin';
    case FieldKind.businessReg:
      return 'business_reg';
    case FieldKind.parcelId:
      return 'parcel_id';
    case FieldKind.date:
      return 'date';
    case FieldKind.choice:
      return 'choice';
  }
}

FieldKind fieldKindFromWire(String s) {
  switch (s) {
    case 'number':
      return FieldKind.number;
    case 'national_id':
      return FieldKind.nationalId;
    case 'tin':
      return FieldKind.tin;
    case 'business_reg':
      return FieldKind.businessReg;
    case 'parcel_id':
      return FieldKind.parcelId;
    case 'date':
      return FieldKind.date;
    case 'choice':
      return FieldKind.choice;
    default:
      return FieldKind.text;
  }
}

@immutable
class FieldRequest {
  const FieldRequest({
    required this.id,
    required this.label,
    required this.purpose,
    required this.kind,
    this.placeholder,
    this.maxLength,
    this.pattern,
    this.choices = const [],
  });

  /// Key used when resubmitting the citizen's message with field_values.
  final String id;
  final String label;
  final String purpose;
  final FieldKind kind;
  final String? placeholder;
  final int? maxLength;
  final String? pattern;
  final List<String> choices;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'purpose': purpose,
        'kind': fieldKindWire(kind),
        if (placeholder != null) 'placeholder': placeholder,
        if (maxLength != null) 'max_length': maxLength,
        if (pattern != null) 'pattern': pattern,
        if (choices.isNotEmpty) 'choices': choices,
      };

  factory FieldRequest.fromJson(Map<String, dynamic> json) {
    return FieldRequest(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      kind: fieldKindFromWire(json['kind'] as String? ?? 'text'),
      placeholder: json['placeholder'] as String?,
      maxLength: json['max_length'] as int?,
      pattern: json['pattern'] as String?,
      choices: ((json['choices'] as List?) ?? const [])
          .map((c) => c as String)
          .toList(growable: false),
    );
  }
}
